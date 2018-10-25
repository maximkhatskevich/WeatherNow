//
//  LocationInfo.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

enum LocationInfo
{
    case unknown
    case loading
    case ready(OpenWeatherAPI.CurrentWeather)
    case failedToLoad(Error)
}
