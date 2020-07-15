//
//  CenterMessageModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct CenterMessageModel: HandyJSON {
    
    var assetId: String?
    var businessType: Int?
    var message: String?
    var smsCreatetime: String?
    var smsErrmsg: String?
    var smsMessage: String?
    var smsModuleId: Int?
    var smsPhone: String?
    var smsStatus: Int?
    var smsType: Int?
    var title: String?
}
