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
        case providerUnavailable(Error)
        case serviceError(Error)
    }
    
    func requestCurrentWeather(
        for location: CLLocationCoordinate2D,
        onSuccess: @escaping (WeatherSnapshot) -> Void,
        onFauilure: @escaping (CurrentWeatherError) -> Void
        )
    {
        let processResponse: (OpenWeatherAPI.CurrentWeatherResult) -> Void = {
            
            switch $0
            {
            case .value(let rawWeather):
                let weather = CurrentWeather.convertToSnapshot(rawWeather)
                onSuccess(weather)

            case .error(let error):
                onFauilure(.serviceError(error))
            }
        }
        
        //---
        
        switch self
        {
        case .ready(let service):
            processResponse(service.currentWeather(for: location))
            
        case .unavailable(let error):
            onFauilure(.providerUnavailable(error))
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
