//
//  AppearanceAppDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/22.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IQKeyboardManager
import PKHUD

final class AppearanceAppDelegate: AppDelegateType {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setupKeyborad()
        }
        self.setupHUD()
        
        return true
    }
    
    private func setupKeyborad() {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    
    private func setupHUD() {
        HUD.dimsBackground = false
        HUD.allowsInteraction = true
    }
}
