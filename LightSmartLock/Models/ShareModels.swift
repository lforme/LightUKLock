//
//  ShareModels.swift
//  IntelligentUOKO
//
//  Created by mugua on 2018/11/2.
//  Copyright © 2018 mugua. All rights reserved.
//

import Foundation
import HandyJSON
import SwiftDate

struct ShareBodyModel: HandyJSON {
    var content: String?
    var title: String?
    var url: String?
    var img: String?
}


struct SharePwdListModel: HandyJSON {
    
    enum SecretType: Int, HandyJSONEnum {
        case single = 1
        case multiple = 2
    }
    
    var shareID: String!
    var tempkeyID: String!
    var shareType: Int!
    var receiveName: String?
    var receivePhone: String?
    var actualReceive: String?
    var received: Bool?
    var mark: String?
    var status: Int!
    var createDate: String?
    var endTime: String?
    var createBy: String?
    var secretType: SecretType!
    var beginTime: String?
    var statusName: String?
    var secretStatus: Int?
}

struct SharePwdLogListModel: HandyJSON {
    
    var createDate: String?
    var receiveName: String?
    var operationType: Int!
    var Content: String?
    
}

struct TempPasswordListModel: HandyJSON {
    
    enum `Type`: Int, HandyJSONEnum {
        case single = 1
        case multiple = 2
    }
    
    var endTime: String?
    var id: String?
    var pwd: String?
    var remark: String?
    var sendTime: String?
    var startTime: String?
    var status: String?
    var type: `Type`!
}

struct TempPasswordRecordLog: HandyJSON {
    
    enum `Type`: Int, HandyJSONEnum {
        case single = 1
        case multiple = 2
    }
    
    enum Status: Int, HandyJSONEnum, CustomStringConvertible {
        case normal = 1
        case withdrawing
        case revoked
        
        var description: String {
            switch self {
            case .normal:
                return "正常"
            case .revoked:
                return "已撤销"
            case .withdrawing:
                return "撤销中"
            }
        }
    }
    
    struct ListModel: HandyJSON {
        var getter: String?
        var status: String?
        var triggerTime: String?
    }
    
    var status: Status?
    var surplusDate: String?
    var type: `Type`!
    var ladderTmpPasswordStatusVOList: [ListModel]?
}
