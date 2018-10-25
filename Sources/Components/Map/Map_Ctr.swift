//
//  Map_Ctr.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/26/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import UIKit
import MapKit

//---

extension Map
{
    typealias Ctr = Map_Ctr
}

//---

final
class Map_Ctr: BaseCtr
{
    // MARK: UI Controls
    
    @IBOutlet
    private
    weak
    var map: MKMapView!
    
    @IBOutlet
    private
    weak
    var doubleTap: UITapGestureRecognizer!
    
    // MARK: UI Actions
    
    @IBAction
    private
    func doubleTapOnMap(
        _ sender: Any
        )
    {
        setLocationAndShowWeather()
    }
}

// MARK: - Gesture Recognizer Support

extension Map_Ctr: UIGestureRecognizerDelegate
{
    func gestureRecognizer(
        _: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
        ) -> Bool
    {
        // assume it's the double tap with map's double tap
        return true
    }
}

// MARK: - Commands

extension Map_Ctr: MKMapViewDelegate
{
    func setLocationAndShowWeather()
    {
        
    }
}
