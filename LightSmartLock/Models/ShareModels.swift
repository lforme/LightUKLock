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
    var Content: String?
    var Title: String?
    var Url: String?
    var Img: String?
    var ShareType: Int!
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
