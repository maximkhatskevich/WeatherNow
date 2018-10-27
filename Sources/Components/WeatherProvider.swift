//
//  WeatherProvider.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation
import CoreLocation

//---

enum WeatherProvider
{
    case ready(OpenWeatherAPI)
    case unavailable(OpenWeatherAPI.InitializationError)
    
    // MARK: Initializers
    
    init(
        with bundle: Bundle = .main
        )
    {
        let bundleInfo = BundleInfo(for: bundle)
        
        //---
        
        self = type(of: self).init(with: bundleInfo.weatherAuthKey)
    }
    
    init(
        with weatherAPIKey: String?
        )
    {
        switch OpenWeatherAPI.initialize(with: weatherAPIKey)
        {
        case .value(let weatherService):
            self = .ready(weatherService)
            
        case .error(let error):
            self = .unavailable(error)
        }
    }
}

// MARK: - Actions

extension WeatherProvider
{
    enum CurrentWeatherError: Error
    {
        case providerUnavailable(OpenWeatherAPI.InitializationError)
        case serviceError(Error)
    }
    
    typealias CurrentWeatherResult = Result<WeatherSnapshot, CurrentWeatherError>
    
    func requestCurrentWeather(
        for location: CLLocationCoordinate2D
        ) -> CurrentWeatherResult
    {
        let processResponse: (OpenWeatherAPI.CurrentWeatherResult) -> CurrentWeatherResult = {
            
            switch $0
            {
            case .value(let rawWeather):
                return .value(CurrentWeather.convertToSnapshot(rawWeather))

            case .error(let error):
                return .error(.serviceError(error))
            }
        }
        
        //---
        
        switch self
        {
        case .ready(let service):
            return processResponse(
                service.currentWeather(
                    for: location
                )
            )
            
        case .unavailable(let error):
            return .error(.providerUnavailable(error))
        }
    }
    
    enum CurrentWeather // scope
    {
        static
        let convertToSnapshot: (OpenWeatherAPI.CurrentWeather) -> WeatherSnapshot = {
            
            WeatherSnapshot(
                name: $0.name,
                temperature: $0.main.temp.flatMap{ Int($0) },
                summary: $0.weather.first?.description,
                countryCode: $0.sys.country,
                timestamp: $0.dt
            )
        }
    }
}
