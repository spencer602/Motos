//
//  LocationGate.swift
//  Moto Strava
//
//  Created by Spencer DeBuf on 12/18/19.
//  Copyright © 2019 Spencer DeBuf. All rights reserved.
//

import Foundation
import MapKit

struct GateModel: Codable, Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location)
        hasher.combine(radius)
    }
    
    private var codableLocation: LocationModel
    
    var location: CLLocation {
        get { return codableLocation.location }
        set { codableLocation = LocationModel(fromCLLocation: newValue) }
    }
    
    var radius: Double
    
    init(location: CLLocation) {
        self.codableLocation = LocationModel(fromCLLocation: location)
        self.radius = 10.0
    }
    
    init(location: CLLocation, withRadius radius: CLLocationDistance) {
        self.codableLocation = LocationModel(fromCLLocation: location)
        self.radius = radius
    }
}
