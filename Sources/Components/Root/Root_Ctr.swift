//
//  Root_Ctr.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreLocation

//---

extension Root
{
    typealias Ctr = Root_Ctr
}

//---

final
class Root_Ctr: UINavigationController
{
    // MARK: App specific - Services
    
    lazy
    var weatherProvider: WeatherProvider = .init()
    
    // MARK: App specific - Data
    
    private(set)
    var locationInfo: LocationInfo = .unknown
    
    // MARK: App specific - UI
    
    private
    var mapCtr: Map.Ctr! // root VC is always there!
    {
        return viewControllers
            .first
            .flatMap{ $0 as? Map.Ctr }
    }
}

// MARK: - Overrides

extension Root_Ctr
{
    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        
        //---
        
        setup()
    }
}

// MARK: - Commands

extension Root_Ctr
{
    func setup()
    {
        // setup components here...
        
        //--- bindings
        
        mapCtr?.bind(with: self)
    }
    
    func requestCurrentWeather(
        for location: CLLocationCoordinate2D
        )
    {
        Do.async{
            
            let result = self.weatherProvider.requestCurrentWeather(
                for: location
            )
            
            //---
            
            Do.onMain{
                
                switch result
                {
                case .value(let weather):
                    self.onWeatherLoadingSuccess(weather)
                    
                case .error(let error):
                    self.onWeatherLoadingFailure(error)
                }
            }
        }
    }
    
//    func showLocationInfo()
//    {
//        performSegue(withIdentifier: "ShowLocaionInfo", sender: nil)
//    }
}

// MARK: - Notifications

extension Root_Ctr
{
    private
    func onWeatherLoadingFailure(
        _ error: WeatherProvider.CurrentWeatherError
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
        _ weather: WeatherSnapshot
        )
    {
        locationInfo = .ready(weather)
        
        //---
        
        // update UI
    }
}
