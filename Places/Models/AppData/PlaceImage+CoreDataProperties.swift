//
//  PlaceImage+CoreDataProperties.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData


extension PlaceImage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceImage> {
        return NSFetchRequest<PlaceImage>(entityName: "PlaceImage")
    }

    @NSManaged public var imageBig: NSData?
    @NSManaged public var place: Place?
}
