//
//  Root_BaseCtr.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit

//---

extension Root
{
    typealias BaseCtr = Root_BaseCtr
}

//---

class Root_BaseCtr: UIViewController
{
    private(set)
    weak
    var parentCoordinator: Root.Ctr?
    
    func bind(
        with parentCoordinator: Root.Ctr
        )
    {
        self.parentCoordinator = parentCoordinator
    }
}
