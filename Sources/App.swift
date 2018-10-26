//
//  App.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit

//---

@UIApplicationMain
class App: UIResponder
{
    // MARK: UIApplicationDelegate support
    
    var window: UIWindow? = UIWindow()
}

// MARK: - UIApplicationDelegate

extension App: UIApplicationDelegate
{
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool
    {
        return true
    }
}
