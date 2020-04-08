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
    
    /////////////
    var avatar: String?
    var bluetoothModel: Bool!
    var cardModel: Bool!
    var codeModel: Bool!
    var fingerprintModel: Bool!
    var id: String?
    var idCard: String?
    var idCardFront: String?
    var idCardReverse: String?
    var kinsfolkTag: String?
    var lockId: String?
    var lockUserAccount: String?
    var nickname: String?
    var phone: String?
    var pressForMoney: Bool!
    var roleType: RoleModel!
    var state: Int!
    var username: String?
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
