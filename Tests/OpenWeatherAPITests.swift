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
        
        switch OpenWeatherAPI.initialize(with: "NonEmptyKey")
        {
        case .value(let service):
            XCTAssertEqual(service.authKey, "NonEmptyKey")
            
        default:
            XCTFail("Didn't get expected value for NON-empty empty string auth key.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "NonEmptyKey", baseAddress: "wR0nG# URL")
        {
        case .error(.invalidBaseAddress):
            break
            
        default:
            XCTFail("Didn't get expected error for INVALID base address.")
        }
        
        //---
        
        switch OpenWeatherAPI.initialize(with: "NonEmptyKey", baseAddress: "http://ok.com")
        {
        case .value(let service):
            XCTAssertEqual(service.baseAddress.absoluteString, "http://ok.com")
            
        default:
            XCTFail("Didn't get expected value for valid base address.")
        }
    }

    func testQueryPreparation()
    {
        guard
            case .value(let service) = OpenWeatherAPI
                .initialize(with: "NonEmptyKey", baseAddress: "http://ok.com")
        else
        {
            return XCTFail("Didn't expect to fail!")
        }
        
        //---
        
        switch service.prepareQuery(
            path: "weather", // OK
            params: [("lat", 37.947), ("lon", -122.953)] // OK
            )
        {
        case .value(let query): // OK
            XCTAssertEqual(
                query.absoluteString,
                "http://ok.com/weather?lat=37.947&lon=-122.953&appid=NonEmptyKey"
            )
            
        default:
            return XCTFail("Didn't expect to fail prepare query with valid params!")
        }
    }

    func testRequestErrorDecoding()
    {
        let validRequestError = """
            {"cod":401,
            "message":"Invalid API key."}
            """
            .data(using: .utf8)!
        
        XCTAssertNotNil(OpenWeatherAPI.checkForRequestError(validRequestError))
        
        //---
        
        let invalidRequestError = """
            {"cod":200,
            "message":"Invalid API key."}
            """
            .data(using: .utf8)!
        
        XCTAssertNil(OpenWeatherAPI.checkForRequestError(invalidRequestError))
        
    }
    
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
            return XCTFail("Failed to prepare sample data.")
        }
        
        //---
        
        let rawWeather: OpenWeatherAPI.CurrentWeather.Snapshot
        
        do
        {
            rawWeather = try OpenWeatherAPI.decodeResponsePayload(rawInput)
        }
        catch
        {
            print(error)
            
            //---
            
            return XCTFail("Failed to decode sample data.")
        }
        
        //---
        
        XCTAssertEqual(rawWeather.main.temp, 289.5)
        XCTAssertEqual(rawWeather.sys.country, "JP")
        
        //---
        
        let weather: WeatherSnapshot = WeatherProvider.convert(rawWeather)
        
        //---
        
        XCTAssertEqual(weather.temperature, 289)
        XCTAssertEqual(weather.countryCode, "JP")
    }
}
