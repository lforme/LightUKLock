//
//  SceneModels.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct UserInSceneModel: HandyJSON {
    
    enum Role: Int, HandyJSONEnum {
        case superAdmin = 0
        case admin
        case member
    }
    
    var customerID: String!
    var accountID: String?
    var sceneID: String!
    var customerNickName: String?
    var phone: String?
    var initialSecret: String?
    var keyID: String?
    var headPic: String?
    var userCode: String?
    var Label: String?
    var relationType: Role! // 0 是管理员
    var pwdNumber: String? // 新添加字段, 服务器也要添加, 蓝牙添加指纹之后返回的编号
}


struct SceneListModel: HandyJSON {
    
    var sceneID: String!
    var sceneName: String?
    var address: String?
    var areaCode: String?
    var accountName: String?
    var ownerAccountID: String!
    var createBy: String?
    var createDate: String?
    var modifyBy: String?
    var modifyDate: String?
    var isDelete: Bool!
    var sort: Int?
    var villageName: String?
    var devNoticeCount: Int?
    var IsInstallLock: Bool!
    var lockType: String?
    var customerLockID: String?
    var assetsID: String?
    
}
