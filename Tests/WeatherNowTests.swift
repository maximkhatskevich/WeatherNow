//
//  WeatherNowTests.swift
//  WeatherNowTests
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import XCTest

@testable
import WeatherNow

class WeatherNowTests: XCTestCase
{
    func testCurrentWeatherDecoding()
    {
        /**
         Seed data structure:
         https://openweathermap.org/current#geo
         */
        let sourceInfo = """
            {"coord":{"lon":139,"lat":35},
            "sys":{"country":"JP","sunrise":1369769524,"sunset":1369821049},
            "weather":[{"id":804,"main":"clouds","description":"overcast clouds","icon":"04n"}],
            "main":{"temp":289.5,"humidity":89,"pressure":1013,"temp_min":287.04,"temp_max":292.04},
            "wind":{"speed":7.31,"deg":187.002},
            "rain":{"3h":0},
            "clouds":{"all":92},
            "dt":1369824698,
            "id":1851632,
            "name":"Shuzenji",
            "cod":200}
            """
        
        //---
        
        guard
            let rawInput = sourceInfo.data(using: .utf8)
        else
        {
            XCTFail("Failed to prepare sample data")
            
            //---
            
            return
        }
        
        //---
        do
        {
            let rawWeather = try JSONDecoder()
                .decode(OpenWeatherAPI.CurrentWeather.self, from: rawInput)
            
            let weather = WeatherProvider
                .CurrentWeather
                .convertToSnapshot(rawWeather)
            
            //---
            
            XCTAssertEqual(weather.temperature, 289)
            XCTAssertEqual(weather.countryCode, "JP")
        }
        catch
        {
            print(error)
            XCTFail("Failed to decode sample data.")
        }
    }
}
