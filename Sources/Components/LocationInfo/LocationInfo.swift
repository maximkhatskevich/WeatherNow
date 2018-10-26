//
//  LocationInfo.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import CoreLocation

//---

enum LocationInfo
{
    case unknown
    case loading(CLLocationCoordinate2D)
    case ready(WeatherSnapshot)
    case failedToLoad(WeatherProvider.CurrentWeatherError)
}
