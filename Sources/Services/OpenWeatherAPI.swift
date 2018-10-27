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
    
    // MARK: Initializers
    
    /**
     PRIVATE on purpose, use 'initialize' instead!
     */
    private
    init(
        _ authKey: String,
        _ baseAddress: URL
        )
    {
        self.authKey = authKey
        self.baseAddress = baseAddress
    }
}

// MARK: - Initialization

extension OpenWeatherAPI
{
    enum InitializationError: Error
    {
        case emptyAuthKey
        case invalidBaseAddress
    }
    
    typealias InitializationResult = Result<OpenWeatherAPI, InitializationError>
    
    static
    func initialize(
        with authKey: String?,
        baseAddress: String = "https://api.openweathermap.org/data/2.5/"
        ) -> InitializationResult
    {
        guard
            let authKey = authKey,
            authKey.count > 0
        else
        {
            return .error(InitializationError.emptyAuthKey)
        }
        
        //---
        
        guard
            let baseAddress = URL(string: baseAddress)
        else
        {
            return .error(InitializationError.invalidBaseAddress)
        }
        
        //---
        
        return .value(.init(authKey, baseAddress))
    }
}

// MARK: - Query Preparation

extension OpenWeatherAPI
{
    enum PrepareQueryError: Error
    {
        case unableToConstructURLComponents
        case unableToConstructFinalURL
    }
    
    typealias PrepareQueryResult = Result<URL, PrepareQueryError>
    
    private
    func prepareQuery(
        path: String,
        params: [(String, Any)]
        ) -> PrepareQueryResult
    {
        guard
            var comps = URLComponents(
                string: self.baseAddress.appendingPathComponent(path).absoluteString
            )
        else
        {
            return .error(PrepareQueryError.unableToConstructURLComponents)
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
            return .error(PrepareQueryError.unableToConstructFinalURL)
        }
        
        //---
        
        return .value(result)
    }
}

// MARK: - Current Weather

extension OpenWeatherAPI
{
    enum CurrentWeatherError: Error
    {
        case unableToConstructEndpoint(PrepareQueryError)
        case failedToFetchData(Error)
        case failedToDecode(Error)
        case invalidRequest(RequestError)
    }
    
    typealias CurrentWeatherResult = Result<CurrentWeather, CurrentWeatherError>
    
    func currentWeather(
        for location: CLLocationCoordinate2D
        ) -> CurrentWeatherResult
    {
        let query: URL
        
        switch prepareQuery(
            path: "weather",
            params: [("lat", location.latitude), ("lon", location.longitude)]
            )
        {
        case .value(let result):
            query = result
            
        case .error(let error):
            return .error(CurrentWeatherError.unableToConstructEndpoint(error))
        }
        
        //---
        
        let rawResult: Data
        
        do
        {
            rawResult = try Data(contentsOf: query)
        }
        catch
        {
            return .error(.failedToFetchData(error))
        }
        
        //---
        
        // NOTE: before attempt to decode proper data,
        // check if we will be able to decode a request-specific error
        
        if
            let requestError = try? JSONDecoder()
                .decode(RequestError.self, from: rawResult),
            requestError.cod != 200 // proper response has 'cod' property equal 200
        {
            return .error(.invalidRequest(requestError))
        }
        
        //---
        
        let result: CurrentWeather
        
        do
        {
            result = try JSONDecoder().decode(CurrentWeather.self, from: rawResult)
        }
        catch
        {
            return .error(.failedToDecode(error))
        }
        
        //---
        
        return .value(result)
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
