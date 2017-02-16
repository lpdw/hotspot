//
//  HotSpot.swift
//  Hotspot
//
//  Created by Léa Motisi on 16/02/2017.
//  Copyright © 2017 Team Rocket. All rights reserved.
//

import UIKit
import MapKit

class HotSpot: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }


}
