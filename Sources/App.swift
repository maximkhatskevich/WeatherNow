//
//  App.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreLocation

//---

@UIApplicationMain
class App: UIResponder
{
    // MARK: UIApplicationDelegate support
    
    var window: UIWindow? = UIWindow()
    
    // MARK: App specific - Services
    
    private
    var weatherProvider: WeatherProvider = .unknown
    
    // MARK: App specific - Data
    
    var locationInfo: LocationInfo = .unknown
    
    // MARK: App specific - UI
    
    private
    var rootCtr: UINavigationController?
    {
        return window
            .flatMap{ $0.rootViewController }
            .flatMap{ $0 as? Root.Ctr }
    }
    
    private
    var mapCtr: Map.Ctr?
    {
        return rootCtr
            .flatMap{ $0.viewControllers.first }
            .flatMap{ $0 as? Map.Ctr }
    }
}

// MARK: - UIApplicationDelegate

extension App: UIApplicationDelegate
{
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool
    {
        do
        {
            let weatherService = try OpenWeatherAPI(authKey: Config().openWeatherAuthKey)
            
            //---
            
            weatherProvider = .ready(weatherService)
        }
        catch
        {
            weatherProvider = .unavailable(error)
        }
        
        //---
        
        mapCtr?.bind(with: self)
        
        //---
        
        return true
    }
}

// MARK: - Commands

extension App
{
    func requestCurrentWeather(
        for location: CLLocationCoordinate2D
        )
    {
        weatherProvider.requestCurrentWeather(
            for: location,
            onSuccess: onWeatherLoadingSuccess,
            onFauilure: onWeatherLoadingFailure
        )
    }
}

// MARK: - Notifications

extension App
{
    private
    func onWeatherLoadingFailure(
        for error: WeatherProvider.CurrentWeatherError
        )
    {
        locationInfo = .failedToLoad(error)
        
        //---
        
        // update UI
    }
    
    private
    func onWeatherLoading(
        for location: CLLocationCoordinate2D
        )
    {
        locationInfo = .loading(location)
        
        //---
        
        // update UI
    }
    
    private
    func onWeatherLoadingSuccess(
        weather: WeatherSnapshot
        )
    {
         locationInfo = .ready(weather)
        
        //---
        
        // update UI
    }
}
