//
//  StaticConst.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

let kLSRem = UIScreen.main.bounds.width / 375

enum NotificationRefreshType {
    case editLock
    case deleteScene
    case updateScene
    case changeDigitalPwd(String?)
    case editMember
    case editCard
    case editFinger
    case tempPassword
    case billFlow
    case accountWay
    case openDoor
    case makeNote
    case steward
}

extension NSNotification.Name {
    
    static let statuBarDidChange = NSNotification.Name(rawValue: "statuBarDidChange")
    static let refreshState = NSNotification.Name(rawValue: "refreshState")
    static let siriOpenDoor = NSNotification.Name(rawValue: "siriOpenDoor")
    static let tokenExpired = NSNotification.Name(rawValue: "tokenExpired")
}


struct PlatformKey {
    static let gouda = "caed09caa3daeca4a11a9eb671294d65"
    static let jpushAppKey = "491b7c3b5a3b231de8cc38c0"
    static let qqAppId = "101883730"
    static let qqAppKey = "ca99adc8b70ea8e97de8abc76f204907"
    static let wechatId = "wxa3043eaf33286039"
    static let wechatSecret = "b2cd55a6bdc5f9fd90973ce6c0232cd3"
    
    static let wechaUniversalLink = "https://m1cok.share2dlink.com/"
    static let qqUniversalLink = "https://m1cok.share2dlink.com/qq_conn/101883730"
}

enum ShareUserDefaultsKey: String, CaseIterable {
    
    case groupId = "group.lightsmartlock.sharedata"
    case token = "group.token"
    case scene = "group.scene"
    case userInfo = "group.user"
    case lockDevice = "group.lockDevice"
}
