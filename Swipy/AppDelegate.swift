//
//  AppDelegate.swift
//  Swipy
//
//  Created by Niklas Olsson on 24/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Utils.sharedInstance.isMainViewLoaded = false
        
        let userStore = NSUserDefaults.standardUserDefaults()
        if userStore.objectForKey("ApplicationUniqueIdentifier") == nil {
            let UUID = NSUUID().UUIDString
            userStore.setObject(UUID, forKey: "ApplicationUniqueIdentifier")
            userStore.synchronize()
        }
        
        //-----------PUSHWOOSH PART-----------
        // set custom delegate for push handling, in our case - view controller
        var pushManager = PushNotificationManager.pushManager()
        pushManager.delegate = self
        
        // handling push on app start
        pushManager.handlePushReceived(launchOptions)
        
        // make sure we count app open in Pushwoosh stats
        pushManager.sendAppOpen()
        
        // register for push notifications!
        pushManager.registerForPushNotifications()
        
        //-----------GoogleAnalytics-----------
        // Optional: automatically send uncaught exceptions to Google Analytics.
        // GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        // GAI.sharedInstance().dispatchInterval = 20.0
        
        // Optional: set Logger to VERBOSE for debug information.
        // GAI.sharedInstance().logger.logLevel = kGAILogLevelVerbose
        
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId("UA-58002902-2")
        
        return true
    }
    
    // system push notification registration success callback, delegate to pushManager
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushNotificationManager.pushManager().handlePushRegistration(deviceToken)
    }
    
    // system push notification registration error callback, delegate to pushManager
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PushNotificationManager.pushManager().handlePushRegistrationFailure(error)
    }
    
    // system push notifications callback, delegate to pushManager
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PushNotificationManager.pushManager().handlePushReceived(userInfo)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        updateFilter()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        Utils.sharedInstance.handleUrl(url)
        
        return true
    }
    
    func updateFilter() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let lastUpdate = userStore.doubleForKey("lastUpdateKey")
        
        let now = NSDate()
        let nowVal = now.timeIntervalSince1970
        
        if nowVal - lastUpdate < 1*24*60*60 {
            return
        }
        
        APIClient.sharedInstance.getFilter(
            { (filterInfo: [String : AnyObject]) -> Void in
                Utils.sharedInstance.filterInfo = filterInfo
                Utils.sharedInstance.saveFilterInfo()
                
                userStore.setDouble(nowVal, forKey: "lastUpdateKey")
                userStore.synchronize()
            }, failure: { (error: NSError!) -> Void in
                println("Error: " + error.localizedDescription)
        })
    }
    
    func onPushAccepted(pushManager: PushNotificationManager!, withNotification pushNotification: [NSObject : AnyObject]!) {
        NSLog("Push notification received")
    }

}
