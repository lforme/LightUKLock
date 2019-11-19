//
//  UserModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct UserModel: HandyJSON {
    var accountID: String!
    var userName: String?
    var phone: String!
    var userLoginName: String?
    var weixinNum: String?
    var cardID: String?
    var headPic: String?
    var gesturePassword: String?
    var loginPassword: String?
    var accountType: Int!
    var createBy: String?
    var createDate: String?
    var modifyBy: String?
    var modifyDate: String?
    var isDelete: Bool!
}
