//
//  WeatherProviderTests.swift
//  WeatherNowTests
//
//  Created by Maxim Khatskevich on 10/28/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import XCTest

@testable
import WeatherNow

//---

class WeatherProviderTests: XCTestCase
{
    func testInitialization()
    {
        switch WeatherProvider.init(with: nil) // INVALID key
        {
        case .unavailable(.emptyAuthKey):
            break // OK
            
        default:
            XCTFail("Expected to fail with INVALID API key!")
        }
        
        //---
        
        switch WeatherProvider.init(with: "") // INVALID key
        {
        case .unavailable(.emptyAuthKey):
            break // OK
            
        default:
            XCTFail("Expected to fail with INVALID API key!")
        }
        
        //---
        
        switch WeatherProvider.init(with: "NonEmptyKey") // key OK
        {
        case .ready(_):
            break
            
        default:
            XCTFail("Didn't expected to fail with valid API key!")
        }
    }
    
    func testCurrentWeatherDecoding()
    {
        let rawWeather = OpenWeatherAPI.CurrentWeather.Snapshot(
            dt: Date(),
            name: nil,
            sys: OpenWeatherAPI.CurrentWeather.Snapshot.Sys(country: "GB"),
            weather: [],
            main: OpenWeatherAPI.CurrentWeather.Snapshot.Main(temp: 23.7)
        )
        
        //---
        
        let weather: WeatherSnapshot = WeatherProvider.convert(rawWeather)
        
        //---
        
        XCTAssertEqual(weather.temperature, 23)
        XCTAssertEqual(weather.countryCode, "GB")
    }
}
