//
//  AppDelegate.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // Restore the state of the application and any running downloads.
        StreamPersistenceManager.sharedManager.restorePersistenceManager()

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
