//
//  Place+CoreDataClass.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Place)
public class Place: NSManagedObject {
    
    //MARK: - Adding Place
    class func newPlace(name: String) -> Place {
        let place = Place(context: CoreDataManager.sharedInstance.managedObjectContext)
        
        place.name = name
//        place.date = NSDate()
        
        return place
    }
    
    //MARK - Appending images to the Place
    var imageActual: UIImage? {
        set {
            if newValue == nil {
                if self.imageBig != nil {
                    CoreDataManager.sharedInstance.managedObjectContext.delete(self.imageBig!)
                }
                self.imageSmall = nil
            } else {
                if self.imageBig == nil {
                    self.imageBig = PlaceImage(context: CoreDataManager.sharedInstance.managedObjectContext)
                }
                self.imageBig?.imageBig = newValue!.jpegData(compressionQuality: 1) as NSData?
                self.imageSmall = newValue!.jpegData(compressionQuality: 0.05) as NSData?
            }
            //date = NSDate()
        }
        
        get {
            if self.imageBig != nil {
                if imageBig?.imageBig != nil {
                    return UIImage(data: self.imageBig!.imageBig! as Data)
                }
            }
            return nil
        }
    }
    
    func addImage(image: UIImage) {
        let placeImage = PlaceImage(context: CoreDataManager.sharedInstance.managedObjectContext)
        
        placeImage.imageBig = image.jpegData(compressionQuality: 1.0) as NSData?
        self.imageBig = placeImage
    }
    
    //MARK - Appending location to the Place
    var locationActual: LocationCoordinate? {
        set {
            if newValue == nil && self.location != nil {
                CoreDataManager.sharedInstance.managedObjectContext.delete(self.location!)
            }
            if newValue != nil && self.location != nil {
                self.location?.latitude = newValue!.lat
                self.location?.longitude = newValue!.lon
            }
            if newValue != nil && self.location == nil {
                let newLocation = Location(context: CoreDataManager.sharedInstance.managedObjectContext)
                
                newLocation.latitude = newValue!.lat
                newLocation.longitude = newValue!.lon
                
                self.location = newLocation
            }
        }
        get {
            if self.location == nil {
                return nil
            } else {
                return LocationCoordinate(lat: self.location!.latitude, lon: self.location!.longitude)
            }
        }
    }
    
    func addCurrentLocation() {
        LocationManager.sharedInstance.getCurrentLocation { (location) in
            self.locationActual = location
        }
    }
    
    func addLocation(latitude: Double, longitude: Double) {
        let placeLocation = Location(context: CoreDataManager.sharedInstance.managedObjectContext)
        
        placeLocation.latitude = latitude
        placeLocation.longitude = longitude
        
        self.location = placeLocation
    }
    
    //MARK: - Converting date
    var dateString: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        return df.string(from: self.date! as Date)
    }
    
}
