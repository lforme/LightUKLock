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
