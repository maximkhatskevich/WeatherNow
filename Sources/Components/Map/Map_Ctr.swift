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
}

// MARK: - Double Tap Handling

extension Map_Ctr: UIGestureRecognizerDelegate
{
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool
    {
        // here we expect that iOS asks us if we want our custom
        // double tap gesture recognizer should be triggered
        // simultaneously with map view built-in double tap recognizer,
        // which is of type 'MKTwoFingerPanGestureRecognizer' (undocumented)
        return true
    }

    @IBAction
    private
    func setLocationAndShowWeather(
        sender: UITapGestureRecognizer
        )
    {
        guard sender.state == .recognized else { return }
        
        //---
        
        let screenLocation = sender.location(in: map)
        let geoLocation = map.convert(screenLocation, toCoordinateFrom: map)
        
        app?.requestCurrentWeather(for: geoLocation)
    }
}

// MARK: - Commands

extension Map_Ctr
{
    //
}
