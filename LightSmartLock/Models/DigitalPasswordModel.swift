//
//  DigitalPasswordModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct DigitalPasswordModel: HandyJSON {
    var keyID: String!
    var keyNum: String?
    var keySecret: String?
    var customerLockID: String?
    var customerID: String?
    var keyType: Int!
    var beginTime: String?
    var endTime: String?
    var status: Int!
    var lockNum: String?
    var mark: String?
    var extendKeyID: String?
    var modifyDate: String?
}

struct DigitalPasswordLogModel: HandyJSON {
    
    var createDate: String!
    var statusValue: Int!
    var statusName: String?
    var content: String?
}
