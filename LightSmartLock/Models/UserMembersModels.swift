//
//  UserMembersModels.swift
//  IntelligentUOKO
//
//  Created by mugua on 2018/11/5.
//  Copyright © 2018 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct UserMemberListModel: HandyJSON {
    
    var customerID: String!
    var accountID: String!
    var sceneID: String!
    var customerNickName: String?
    var phone: String?
    var keyID: String!
    var headPic: String?
    
    var codeModel: Bool = false
    var fingerprintModel: Bool = false
    var cardModel: Bool = false
    var bluetoothModel: Bool = false
    
    var userCode: String?
    var createDate: String!
    
    var Label: String?
    var initialSecret: String?
    
    var relationType: RoleModel?
}

struct AddUserMemberModel: HandyJSON {
    
    var SceneID: String?
    var CustomerNickName: String?
    var Phone: String?
    var InitialSecret: String?
    var UserCode: String?
    var OperationType: Int?
    var Label: String?
    var HeadPic: String?
}
