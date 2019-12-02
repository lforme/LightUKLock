//
//  PositionModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct PositionModel: HandyJSON {
    
    var accountID: String!
    var assetsID: String!
    var assetsName: String?
    var villageName: String?
    var villageAddress: String?
    var area: String?
    var houseType: String?
    var towards: String?
    var doorplate: String?
    var city: String?
    var region: String?
    var regionCode: String?
    var createDate: String?
    var createBy: String?
    var modifyDate: String?
    var modifyBy: String?
    var isDelete: Bool!
    var sceneID: String?
    var building: String?
    var unit: String?
}
