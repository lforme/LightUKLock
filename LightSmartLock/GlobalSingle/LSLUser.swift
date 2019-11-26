//
//  LSLUser.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LSLUser: NSObject {
    
    private let lock = NSRecursiveLock()
    
    private override init() {
        lock.name = "com.LSLUser.lock"
        super.init()
    }
    
    private static let instance = LSLUser()
    
    static func current() -> LSLUser {
        return LSLUser.instance
    }
    
    func logout() {
        
        let diskCache = NetworkDiskStorage(autoCleanTrash: true, path: "network")
        diskCache.deleteValueBy(user?.accountID)
        
        Keys.allCases.forEach {
            LocalArchiver.remove(key: $0.rawValue)
        }
        token = nil
        refreshToken = nil
        user = nil
        userInScene = nil
        scene = nil
        lockInfo = nil
        NotificationCenter.default.post(name: .loginStateDidChange, object: false)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    var token: AccessTokenModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.token.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.token.rawValue) as? [String: Any]
            let value = AccessTokenModel.deserialize(from: json)
            return value
        }
    }
    
    var refreshToken: AccessTokenModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.refreshToekn.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.refreshToekn.rawValue) as? [String: Any]
            let value = AccessTokenModel.deserialize(from: json)
            return value
        }
    }
    
    var user: UserModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            changeableUserInfo.accept(value)
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.userInfo.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.userInfo.rawValue) as? [String: Any]
            let value = UserModel.deserialize(from: json)
            return value
        }
    }
    
    var userInScene: UserInSceneModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.userInScene.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.userInScene.rawValue) as? [String: Any]
            let value = UserInSceneModel.deserialize(from: json)
            return value
        }
    }
    
    var scene: SceneListModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            changeableScene.accept(value)
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.scene.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.scene.rawValue) as? [String: Any]
            let value = SceneListModel.deserialize(from: json)
            return value
        }
    }
    
    var lockInfo: SmartLockInfoModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.smartLockInfo.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.smartLockInfo.rawValue) as? [String: Any]
            let value = SmartLockInfoModel.deserialize(from: json)
            return value
        }
    }
    
    var lockIOTInfo: IOTLockInfoModel? {
        set {
            guard let value = newValue, let json = value.toJSON() else { return }
            lock.lock()
            LocalArchiver.save(key: LSLUser.Keys.lockIOTInfo.rawValue, value: json)
            lock.unlock()
        }
        
        get {
            let json = LocalArchiver.load(key: LSLUser.Keys.lockIOTInfo.rawValue) as? [String: Any]
            let value = IOTLockInfoModel.deserialize(from: json)
            return value
        }
    }
    
    var obUserInfo: Observable<UserModel?> {
        return changeableUserInfo.asObservable()
    }
    
    var obScene: Observable<SceneListModel?> {
        return changeableScene.asObservable()
    }
    
    var isLogin: Bool {
        return (user != nil) ? true : false
    }
    
    var isInstalledLock: Bool {
        guard let sceneModel = self.scene else {
            return false
        }
        return sceneModel.IsInstallLock
    }
    
    private let changeableUserInfo = BehaviorRelay<UserModel?>(value: nil)
    private let changeableScene = BehaviorRelay<SceneListModel?>(value: nil)
}

/// 归档的Key
extension LSLUser {
    enum Keys: String, CaseIterable {
        case refreshToekn = "refreshToeknModel"
        case token = "tokenModel"
        case userInScene = "userInSceneModel"
        case scene = "currentSceneModel"
        case userInfo = "userInfoModel"
        case smartLockInfo = "smartLockInfo"
        case lockIOTInfo = "lockIOTInfo"
    }
}

