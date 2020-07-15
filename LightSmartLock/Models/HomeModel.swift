//
//  HomeModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct HomeModel: HandyJSON {
    
    struct LadderHomeOwnerVO: HandyJSON {
        var houseValue: Double!
        var mom: Double!
        var price: Double!
    }
    
    struct LadderHomeTenantVO: HandyJSON {
        var endTime: String?
        var ownerName: String?
        var startTime: String?
    }
    
    struct LadderOpenLockRecordVO: HandyJSON {
        var openTime: String?
        var openType: String?
        var userName: String?
    }
    
    var power: Double?
    var powerPercent: Double?
    var onlineStatus: Bool?
    var openStatus: Bool?
    var ladderHomeOwnerVO: LadderHomeOwnerVO?
    var ladderHomeTenantVO: LadderHomeTenantVO?
    var ladderOpenLockRecordVO: LadderOpenLockRecordVO?
    var unReadMsg: Int?
}

