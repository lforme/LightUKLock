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
