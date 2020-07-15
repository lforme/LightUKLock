//
//  ShareSDKAppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation

final class ShareSDKAppDelegate: AppDelegateType {
    
    @discardableResult
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        setupShareSDK()
        
        return true
    }
    
    private func setupShareSDK() {
        ShareSDK.registPlatforms { (platformsRegister) in
            
            platformsRegister?.setupQQ(withAppId: PlatformKey.qqAppId, appkey: PlatformKey.qqAppKey, enableUniversalLink: false, universalLink: PlatformKey.qqUniversalLink)
            
            platformsRegister?.setupWeChat(withAppId: PlatformKey.wechatId, appSecret: PlatformKey.wechatSecret, universalLink: PlatformKey.wechaUniversalLink)
        }
    }
}
