//
//  Trip.swift
//  speeding
//
//  Created by hackintosh on 4/8/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Trip {
    
    let startingPoint: CLLocation
    let stops: [CLLocation]
    let finalDestination: CLLocation
    var stopsTime: TimeInterval?
    var totalTime: TimeInterval?
    var tripTitle: String?
    
    init(starting: CLLocation, stops: [CLLocation], final: CLLocation) {
        self.startingPoint = starting
        self.stops = stops
        self.finalDestination = final
    }
    
}
