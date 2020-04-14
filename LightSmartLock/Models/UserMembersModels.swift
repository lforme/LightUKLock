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
    var operationType: Int! // 1 蓝牙  2远程
    var bluetoothPwd: String? // 蓝牙密码
    
    struct ModifyNickname: HandyJSON {
        var id: String?
        var nickname: String?
    }
    
    func ConvertToModifyNickname() -> ModifyNickname {
        let model = ModifyNickname(id: self.id, nickname: self.nickname)
        return model
    }
}

