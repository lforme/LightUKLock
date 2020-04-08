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
    var secretKey: String?
    var bluthName: String?
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


struct UnlockRecordModel: HandyJSON {
    
    enum KeyType: Int, HandyJSONEnum, CustomStringConvertible {
        case password = 1
        case finger
        case ICCard
        case identifyCard
        case tempPassword
        case bluetooth
        
        var description: String {
            switch self {
            case .bluetooth:
                return "蓝牙解锁"
            case .finger:
                return "指纹解锁"
            case .ICCard:
                return "IC卡解锁"
            case .identifyCard:
                return "身份证解锁"
            case .password:
                return "密码解锁"
            case .tempPassword:
                return "临时密码解锁"
            }
        }
    }
    
    var LockNum: String?
    var UserCode: String?
    var KeyType: KeyType!
    var KeyID: String?
    var UnlockTime: String!
    var CustomerID: String!
    var headPic: String?
    var customerNickName: String?
}

struct LockModel: HandyJSON {
    var bluetoothName: String?
    var bluetoothPwd: String?
    var bluetoothVersion: String?
    var deviceType: String?
    var fingerVersion: String?
    var firmwareVersion: String?
    var imei: String?
    var imsi: String?
    var blueMac: String?
    var ladderAssetHouseId: String?
    var lockCode: String?
    var lockType: String?
    var nbVersion: String?
    var serialNumber: String?
    var adminPwd: String?
    var power: Double?
    var powerPercent: Double?
    var signal: String?
    var ladderLockId: String?
    
}
