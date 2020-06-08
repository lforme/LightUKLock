//
//  AppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/18.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum AppDelegateFactory {
        
        static func makeDefault() -> AppDelegateType {
            return CompositeAppDelegate(appDelegates: [
                PushNotificationsAppDelegate(),
                AppearanceAppDelegate(),
                ShareSDKAppDelegate()
                ]
            )
        }
    }
    
    private let appDelegate = AppDelegateFactory.makeDefault()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        _ = appDelegate.application?(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        appDelegate.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appDelegate.applicationDidBecomeActive?(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        appDelegate.applicationDidEnterBackground?(application)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.webpageURL?.absoluteString.contains("share2dlink") == true {
            return appDelegate.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? true
        }
        NotificationCenter.default
            .post(name: .siriOpenDoor, object: nil)
        
        return appDelegate.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? true
    }
}

extension AppDelegate {
    
    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        NotificationCenter.default.post(name: .statuBarDidChange, object: style)
    }
}
