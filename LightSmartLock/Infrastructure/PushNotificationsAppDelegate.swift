//
//  PushNotificationsAppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/22.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

final class PushNotificationsAppDelegate: AppDelegateType, JPUSHRegisterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let jpEntity = JPUSHRegisterEntity()
        jpEntity.types = Int(UInt8(JPAuthorizationOptions.alert.rawValue) | UInt8(JPAuthorizationOptions.badge.rawValue) | UInt8(JPAuthorizationOptions.sound.rawValue))
        JPUSHService.register(forRemoteNotificationConfig: jpEntity, delegate: self)
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: PlatformKey.jpushAppKey, channel: "iOS", apsForProduction: false)
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: PlatformKey.jpushAppKey, channel: "iOS", apsForProduction: true)
        #endif
        
        if let userId = LSLUser.current().user?.id {
            print(userId)
            JPUSHService.setAlias(userId, completion: { (code, alias, seq) in
                print("极光注册别名:\(String(describing: alias))")
            }, seq: 1)
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("通知注册失败:\(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // do something
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo
        print(userInfo.description)
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo.description)
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            
            print(userInfo)
        }
        completionHandler()
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) { }
}
