//
//  OpenWeatherAPI_CurrentWeather.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/28/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation
import CoreLocation

//---

extension OpenWeatherAPI
{
    struct CurrentWeather // scope/proxy
    {
        let service: OpenWeatherAPI
    }
    
    var currentWeather: CurrentWeather
    {
        return .init(service: self)
    }
}

//---

extension OpenWeatherAPI.CurrentWeather
{
    /**
     Docs: https://openweathermap.org/current
     */
    struct Snapshot: Decodable
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
    
    enum Error: Swift.Error
    {
        case unableToConstructEndpoint(OpenWeatherAPI.PrepareQueryError)
        case failedToFetchData(Swift.Error)
        case failedToDecode(Swift.Error)
        case invalidRequest(OpenWeatherAPI.RequestError)
    }
    
    typealias RequestResult = Result<Snapshot, Error>
    
    func get(
        for location: CLLocationCoordinate2D
        ) -> RequestResult
    {
        let query: URL
        
        switch service.prepareQuery(
            path: "weather",
            params: [("lat", location.latitude), ("lon", location.longitude)]
            )
        {
        case .value(let result):
            query = result
            
        case .error(let error):
            return .error(.unableToConstructEndpoint(error))
        }
        
        //---
        
        let rawResult: Data
        
        do
        {
            // NOTE: request to network,
            // this must be executed on a background queue!
            rawResult = try service.fetchData(for: query)
        }
        catch
        {
            return .error(.failedToFetchData(error))
        }
        
        //---
        
        // NOTE: before attempt to decode proper data,
        // check if we will be able to decode a request-specific error
        
        if
            let requestError = service.checkForRequestError(rawResult)
        {
            return .error(.invalidRequest(requestError))
        }
        
        //---
        
        let result: Snapshot
        
        do
        {
            result = try service.decodeResponsePayload(rawResult)
        }
        catch
        {
            return .error(.failedToDecode(error))
        }
        
        //---
        
        return .value(result)
    }
}
