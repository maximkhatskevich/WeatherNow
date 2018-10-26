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

// MARK: - Current Weather

extension OpenWeatherAPI
{
    enum CurrentWeatherError: Error
    {
        case unableToConstructEndpoint
        case failedToDecode(Error)
        case failedToFetchData(Error)
    }
    
    typealias CurrentWeatherResult = Result<CurrentWeather, CurrentWeatherError>
    
    func currentWeather(
        for location: CLLocationCoordinate2D,
        _ completion: @escaping (CurrentWeatherResult) -> Void
        )
    {
        guard
            let endpoint = URL(string: "weather", relativeTo: self.baseAddress)
        else
        {
            // to stay consistent, return async-ly on main
            // as we would do after network request
            onMain{ completion(.error(CurrentWeatherError.unableToConstructEndpoint)) }
            
            //---
            
            return
        }
        
        //---
        
        onBg{
            
            let rawResult: Data
            
            do{
                
                rawResult = try Data(contentsOf: endpoint)
            }
            catch
            {
                self.onMain{ completion(.error(.failedToFetchData(error))) }
                
                //---
                
                return
            }
            
            //---
            
            let result: CurrentWeather
            
            do{
                
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
        
        let td: Date
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
