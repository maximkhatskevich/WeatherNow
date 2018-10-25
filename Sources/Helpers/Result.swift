//
//  Result.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

enum Result<V, E: Error>
{
    case value(V)
    case error(E)
}
