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
        print(CoreDataManager.sharedInstance.persistentContainer.persistentStoreDescriptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.sharedInstance.saveContext()
    }

    

}
