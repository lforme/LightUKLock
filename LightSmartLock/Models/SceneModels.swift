//
//  SceneModels.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

enum RoleModel: Int, HandyJSONEnum, CustomStringConvertible {
    case superAdmin = 1
    case admin
    case member
    
    var description: String {
        switch self {
        case .superAdmin:
            return "超级管理员"
        case .admin:
            return "管理员"
        case .member:
            return "成员"
        }
    }
}


struct SceneListModel: HandyJSON {
    
    // 新的
    var buildingAdress: String?
    var buildingName: String?
    var cityId: String?
    var cityName: String?
    var isTop: Bool!
    var ladderAssetHouseId: String?
    var ladderLockId: String?
    var lockType: String?
    var roleType: RoleModel!
    var unReadMsg: Int!
    var lockUserAccount: String?
}

class AssetPendingModel: HandyJSON, Hashable {
    
    static func == (lhs: AssetPendingModel, rhs: AssetPendingModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.buildingAdress)
        hasher.combine(self.buildingName)
        hasher.combine(self.buildingNo)
        hasher.combine(self.floor)
        hasher.combine(self.houseNum)
        hasher.combine(self.isBind)
        hasher.combine(self.ladderAssetHouseId)
    }
    
    required init() {}
    
    var buildingAdress: String?
    var buildingName: String?
    var buildingNo: String?
    var floor: Int?
    var houseNum: String?
    var isBind: Bool?
    var ladderAssetHouseId: String?
}


