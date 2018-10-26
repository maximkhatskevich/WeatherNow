//
//  WeatherSnapshot.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation

//---

struct WeatherSnapshot
{
    let name: String?
    let temperature: Int?
    let summary: String?
    let countryCode: String?
    let timestamp: Date
}
