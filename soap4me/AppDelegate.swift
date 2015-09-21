//
//  AppDelegate.swift
//  soap4me
//
//  Created by Sema Belokovsky on 17/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Appirater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        YMMYandexMetrica.activateWithApiKey("0411d79d-5525-40ba-967e-569ee7afed03")
        
        SMStateManager.sharedInstance.checkVersion()
        SMStateManager.sharedInstance.checkPush()
        
        Appirater.setAppId(String(format: "%d", APP_ID))
        Appirater.setDaysUntilPrompt(7)
        Appirater.setUsesUntilPrompt(2)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(7)
        Appirater.setCustomAlertMessage(NSLocalizedString("Скажите спасибо разработчику - оцените приложение!"))
        Appirater.appLaunched(true)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        SMStateManager.sharedInstance.pushToken = deviceTokenString
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        let exception = NSException(name: "PUSH", reason: error.description, userInfo: error.userInfo)
        YMMYandexMetrica.reportError("PUSH.ERROR", exception: exception, onFailure: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

