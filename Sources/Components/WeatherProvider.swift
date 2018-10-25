//
//  WeatherProvider.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

enum WeatherProvider
{
    case unknown
    case ready(OpenWeatherAPI)
    case unavailable(Error)
}
