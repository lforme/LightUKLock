//
//  LockModels.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct SmartLockInfoModel: HandyJSON {
    
    var InitialSecret: String!
    var UserCode: String!
    var AccountID: String!
    var customerLockID: String!
    var sceneID: String?
    var lockNum: String!
    var secretKey: String!
    var bluthName: String!
    var MAC: String!
    var IMEI: String!
    var lockVersion: String!
    var NBVersion: String!
    var bluthVersion: String!
    var fingerprintVersion: String?
    var SNCode: String!
    var IMSI: String!
    var lockType: String!
}

struct IOTLockInfoModel: HandyJSON {
    
    enum LockStateType: Int, HandyJSONEnum {
        case locked = 0
        case unlocked = 1
    }
    
    var customerLockID: String?
    var sceneID: String?
    var LockNum: String?
    var LastOpenDoorDate: String?
    var LastOpenDoorUserCode: String?
    var LastOpenDoorNikeName: String?
    var LastOpenDoorCustomerID: String?
    var CustomerHeadPic: String?
    var PowerPercent: Float?
    var DaysInt: Int!
    var LockState: LockStateType!
    var NBSignal: String?
    var OnLineState: Int! // 1 开启 0 关闭
    
    func getPower() -> String? {
        guard let p = PowerPercent else {
            return nil
        }
        return String(format: "%.0f", (p * Float(100))) + "%"
    }
}
