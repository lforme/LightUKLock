//
//  DigitalPasswordModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON


struct OpenLockInfoModel: HandyJSON {
    
    struct Card: HandyJSON {
        var createTime: String?
        var id: String?
        var keyNum: String?
        var name: String?
        var status: Int!
    }
    
    struct Finger: HandyJSON {
        var createTime: String?
        var id: String?
        var keyNum: String?
        var name: String?
        var status: Int!
        var phone: String?
    }
    
    struct LadderNumberPasswordRecordVOList: HandyJSON {
        var status: Int!
        var statusName: String?
        var triggerTime: String?
    }
    
    struct LadderNumberPasswordVO: HandyJSON {
        var id: String?
        var password: String?
        var status: Int!
        var statusName: String?
        var useDays: Int?
        var ladderNumberPasswordRecordVOList: [LadderNumberPasswordRecordVOList]?
    }
    
    var ladderCardVOList: [Card]?
    var ladderFingerPrintVOList: [Finger]?
    var ladderNumberPasswordVO: LadderNumberPasswordVO?
}
