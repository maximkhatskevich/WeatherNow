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

//---

class OpenWeatherAPITests: XCTestCase
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
            return XCTFail("Failed to prepare sample data")
        }
        
        //---
        
        let rawWeather: OpenWeatherAPI.CurrentWeather
        
        do
        {
            rawWeather = try JSONDecoder()
                .decode(OpenWeatherAPI.CurrentWeather.self, from: rawInput)
        }
        catch
        {
            print(error)
            
            //---
            
            return XCTFail("Failed to decode sample data.")
        }
        
        //---
        
        let weather = WeatherProvider
            .CurrentWeather
            .convertToSnapshot(rawWeather)
        
        //---
        
        XCTAssertEqual(weather.temperature, 289)
        XCTAssertEqual(weather.countryCode, "JP")
    }
    
    func testInitialization()
    {
        switch OpenWeatherAPI.initialize(with: nil)
        {
        case .error(.emptyAuthKey):
            break
            
        default:
            XCTFail("Didn't get expected error for 'nil' auth key.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "")
        {
        case .error(.emptyAuthKey):
            break
            
        default:
            XCTFail("Didn't get expected error for empty (length == 0) auth key.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "sOmeN0n3EmpT7K3Y")
        {
        case .value(_):
            break
            
        default:
            XCTFail("Didn't get expected value for NON-empty empty string auth key.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "sOmeN0n3EmpT7K3Y", baseAddress: "wR0nG# URL")
        {
        case .error(.invalidBaseAddress):
            break
            
        default:
            XCTFail("Didn't get expected error for INVALID base address.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "sOmeN0n3EmpT7K3Y", baseAddress: "http://ok.com")
        {
        case .value(_):
            break
            
        default:
            XCTFail("Didn't get expected value for valid base address.")
        }
    }
}
