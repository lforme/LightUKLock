//
//  AppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/18.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IQKeyboardManager
import PKHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupKeyborad()
        setupHUD()
        return true
    }

}

extension AppDelegate {
    
    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        NotificationCenter.default.post(name: .statuBarDidChange, object: style)
    }
}

extension AppDelegate {
    
    func setupKeyborad() {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    
    func setupHUD() {
        HUD.dimsBackground = false
        HUD.allowsInteraction = true
    }
}
