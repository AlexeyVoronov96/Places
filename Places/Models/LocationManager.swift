//
//  LocationManager.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreLocation

struct LocationCoordinate {
    var lat: Double
    var lon: Double
    
    static func create(location: CLLocation) -> LocationCoordinate {
        return LocationCoordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()

    //MARK: - Properties
    var manager = CLLocationManager()
    
    func requestAuthorization() {
        self.manager.requestWhenInUseAuthorization()
    }
    
    var blockForSave: ((LocationCoordinate) -> Void)?
    
    //MARK: - Receiving current location
    func getCurrentLocation(block: ((LocationCoordinate) -> Void)?) {
        guard CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse else { return }
        
        self.blockForSave = block
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.activityType = .other
        self.manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lc = LocationCoordinate.create(location: locations.last!)
        self.blockForSave?(lc)
        
        self.manager.stopUpdatingLocation()
    }
}
