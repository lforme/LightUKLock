//
//  FingerModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct FingerModel: HandyJSON {
    var keyID: String?
    var keyNum: String?
    var customerID: String?
    var customerLockID: String?
    var keyType: Int?
    var remindPhone: String?
    var mark: String?
    var createDate: String?
}
