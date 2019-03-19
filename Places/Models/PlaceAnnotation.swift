//
//  File.swift
//  Places
//
//  Created by Алексей Воронов on 05/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    var place: Place
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(place: Place) {
        self.place = place
        title = place.name
        
        if place.locationActual != nil {
            coordinate = CLLocationCoordinate2D(latitude: place.locationActual!.lat, longitude: place.locationActual!.lon)
        } else {
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
}
