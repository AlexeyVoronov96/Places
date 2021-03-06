//
//  AppDelegate.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 2.0)
        UINavigationBar.appearance().shadowImage = UIImage()
        print(CoreDataManager.sharedInstance.persistentContainer.persistentStoreDescriptions)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        for place in places {
            if place.imageActual == nil && place.name == "" {
                CoreDataManager.sharedInstance.managedObjectContext.delete(place)
            }
        }
        CoreDataManager.sharedInstance.saveContext()
    }
}

