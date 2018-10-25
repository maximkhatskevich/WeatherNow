//
//  Root_Ctr.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit

//---

extension Root
{
    typealias Ctr = Root_Ctr
}

//---

final
class Root_Ctr: UINavigationController {}

// MARK: - Commands

extension Root_Ctr
{
    func showLocationInfo()
    {
        performSegue(withIdentifier: "ShowLocaionInfo", sender: nil)
    }
}
