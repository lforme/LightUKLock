//
//  LockModels.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON


struct UnlockRecordModel: HandyJSON, Hashable {
    var openTypeCode: Int?
    var openTime: String?
    var openType: String?
    var userName: String?
    var avatar: String?
    
    static func == (lhs: UnlockRecordModel, rhs: UnlockRecordModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.openTime)
        hasher.combine(self.openType)
        hasher.combine(self.userName)
        hasher.combine(self.openTypeCode)
    }
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
    var lockNum: String?
}

class BindLockListModel: HandyJSON {
    
    var id: String?
    var address: String?
    var snCode: String?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.id <-- "hardwareLockConfigDTO.id"
        mapper <<<
            self.address <-- "hardwareLockConfigDTO.installAddress"
        mapper <<<
            self.snCode <-- "hardwareLockConfigDTO.snCode"
        
    }
}

struct LockTypeModel: HandyJSON {
    var tyeUrl: String?
    var typeId: String?
    var typeName: String?
}
