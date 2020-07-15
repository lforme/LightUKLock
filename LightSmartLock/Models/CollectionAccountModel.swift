//
//  CollectionAccountModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/18.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

class CollectionAccountModel: HandyJSON {
    
    required init() {}
    
    var account: String?
    var accountType: Int?
    var bankBranchName: String?
    var bankName: String?
    var content: String?
    var createBy: String?
    var id: String?
    var isDefault: Bool?
    var paymentCodeUrl: String?
    var userName: String?
}
