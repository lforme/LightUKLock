//
//  CompositeAppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/22.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import UIKit

typealias AppDelegateType = UIResponder & UIApplicationDelegate

class CompositeAppDelegate: AppDelegateType {
    
    private let appDelegates: [AppDelegateType]
    
    init(appDelegates: [AppDelegateType]) {
        self.appDelegates = appDelegates
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        appDelegates.forEach { _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions) }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appDelegates.forEach { _ = $0.applicationDidBecomeActive?(application) }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        appDelegates.forEach { _ = $0.applicationDidBecomeActive?(application) }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        appDelegates.forEach { _ = $0.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken) }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        appDelegates.forEach { _ = $0.application?(application, continue: userActivity, restorationHandler: restorationHandler) }
        
        return true
    }
   
}

