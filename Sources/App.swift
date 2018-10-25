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

protocol AppBindable
{
    func bind(with app: App)
}

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

// MARK: - Commands

extension App
{
    func setup()
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
    }
    
    func setupUI()
    {
        mapCtr?.bind(with: self)
    }
    
}

// MARK: - Notifications

extension App
{
    func loadInfo(
        for location: CLLocationCoordinate2D
        )
    {
        locationInfo = .loading
        
        //---
        
        // load weather using weather service...
    }
}
