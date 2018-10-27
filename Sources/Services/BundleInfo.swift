//
//  BundleInfo.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation

//---

/**
 Wrapper for dealing with info plist.
 */
final
class BundleInfo
{
    private
    let bundle: Bundle
    
    // MARK: Initializers
    
    init(
        for bundle: Bundle = .main
        )
    {
        self.bundle = bundle
    }
}

// MARK: - App Specific Properties

extension BundleInfo
{
    var weatherAuthKey: String?
    {
        return bundle.infoDictionary?["WeatherServiceAPIKey"] as? String
    }
}
