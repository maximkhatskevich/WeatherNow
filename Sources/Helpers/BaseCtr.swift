//
//  BaseCtr.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit

//---

class BaseCtr: UIViewController
{
    private(set)
    weak
    var app: App?
    
    // MARK: AppBindable

    func bind(with app: App)
    {
        self.app = app
    }
    
    // MARK: Overrides

    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        
        //---
        
        setupUI()
    }
    
    // MARK: Commands

    func setupUI()
    {
        //
    }
}
