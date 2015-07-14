//
//  AppDelegate.swift
//  QuickMeeting
//
//  Created by Justin Sheckler on 5/16/15.
//  Copyright (c) 2015 Justin Sheckler. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        var notificationSettings = UIUserNotificationSettings(forTypes: .Sound | .Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("localNotificationReceived", object: notification.userInfo)
    }
    
//    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        return true
//    }
//    
//    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
//        return true
//    }
}

