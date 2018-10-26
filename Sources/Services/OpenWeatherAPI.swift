//
//  OpenWeatherAPI.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation
import CoreLocation

//---

final
class OpenWeatherAPI
{
    // MARK: Type level members
    
    enum InitializationError: Error
    {
        case invalidAuthKey
        case invalidBaseAddress
    }
    
    /**
     Invalid request.
     
     Example:
     {"cod":401, "message": "Invalid API key."}
     */
    struct RequestError: Decodable // NOT an Error, NOT supposed to be used directly as error
    {
        let cod: Int
        let message: String
    }
    
    // MARK: Instance level members
    
    let baseAddress: URL
    
    let authKey: String // API key
    
    private
    let queue: DispatchQueue
    
    // MARK: Initializers
    
    init(
        authKey: String?,
        baseAddress: String = "https://api.openweathermap.org/data/2.5/",
        queue: DispatchQueue = .global(qos: .background)
        ) throws
    {
        guard
            let authKey = authKey,
            authKey.count > 0
        else
        {
            throw InitializationError.invalidAuthKey
        }
        
        //---
        
        guard
            let baseAddress = URL(string: baseAddress)
        else
        {
            throw InitializationError.invalidBaseAddress
        }
        
        //---
        
        self.authKey = authKey
        self.queue = queue
        self.baseAddress = baseAddress
    }
}

// MARK: - Geenral

extension OpenWeatherAPI
{
    enum PrepareQueryError: Error
    {
        case unableToConstructURLComponents
        case unableToConstructFinalURL
    }
    
    private
    func prepareQuery(
        path: String,
        params: [(String, Any)]
        ) throws -> URL
    {
        guard
            var comps = URLComponents(
                string: self.baseAddress.appendingPathComponent(path).absoluteString
            )
        else
        {
            throw PrepareQueryError.unableToConstructURLComponents
        }
        
        //---
        
        comps.queryItems = params
            .map{ URLQueryItem(name: $0.0, value: "\($0.1)") }
            + [URLQueryItem(name: "appid", value: authKey)]
        
        //---
        
        guard
            let result = comps.url
        else
        {
            throw PrepareQueryError.unableToConstructFinalURL
        }
        
        //---
        
        return result
    }
}

// MARK: - Current Weather

extension OpenWeatherAPI
{
    enum CurrentWeatherError: Error
    {
        case unknownError(Error)
        case unableToConstructEndpoint(PrepareQueryError)
        case failedToFetchData(Error)
        case failedToDecode(Error)
        case invalidRequest(RequestError)
    }
    
    typealias CurrentWeatherResult = Result<CurrentWeather, CurrentWeatherError>
    
    func currentWeather(
        for location: CLLocationCoordinate2D,
        _ completion: @escaping (CurrentWeatherResult) -> Void
        )
    {
        let endpoint: URL
        
        //---
        
        do
        {
            endpoint = try prepareQuery(
                path: "weather",
                params: [
                    ("lat", location.latitude),
                    ("lon", location.longitude)
                ]
            )
        }
        catch let error as PrepareQueryError
        {
            // to stay consistent, return async-ly on main
            // as we would do after network request
            onMain{ completion(.error(CurrentWeatherError.unableToConstructEndpoint(error))) }
            
            //---
            
            return
        }
        catch
        {
            // to stay consistent, return async-ly on main
            // as we would do after network request
            onMain{ completion(.error(CurrentWeatherError.unknownError(error))) }
            
            //---
            
            return
        }
        
        //---
        
        onBg{
            
            let rawResult: Data
            
            do
            {
                rawResult = try Data(contentsOf: endpoint)
            }
            catch
            {
                self.onMain{ completion(.error(.failedToFetchData(error))) }
                
                //---
                
                return
            }
            
            //---
            
            if
                let requestError = try? JSONDecoder().decode(RequestError.self, from: rawResult)
            {
                self.onMain{ completion(.error(.invalidRequest(requestError))) }
                
                //---
                
                return
            }
            
            //---
            
            let result: CurrentWeather
            
            do
            {
                result = try JSONDecoder().decode(CurrentWeather.self, from: rawResult)
            }
            catch
            {
                self.onMain{ completion(.error(.failedToDecode(error))) }
                
                //---
                
                return
            }
            
            //---
            
            self.onMain{ completion(.value(result)) }
        }
    }
    
    /**
     Docs: https://openweathermap.org/current
     */
    struct CurrentWeather: Decodable
    {
        struct Sys: Decodable
        {
            let country: String?
        }
        
        struct Weather: Decodable
        {
            let description: String?
        }
        
        struct Main: Decodable
        {
            let temp: Float?
        }
        
        //---
        
        let dt: Date
        let name: String?
        let sys: Sys
        let weather: [Weather]
        let main: Main
    }
}

// MARK: - Internal Helpers

private
extension OpenWeatherAPI
{
    func onBg(
        _ asyncOperation: @escaping () -> Void
        )
    {
        queue.async(execute: asyncOperation)
    }
    
    func onMain(
        _ mainQueueOperation: @escaping () -> Void
        )
    {
        DispatchQueue.main.async(execute: mainQueueOperation)
    }
}
