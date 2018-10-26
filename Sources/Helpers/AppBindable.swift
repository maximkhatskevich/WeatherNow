//
//  AppBindable.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

protocol AppBindable: AnyObject
{
    func bind(with app: App)
}
