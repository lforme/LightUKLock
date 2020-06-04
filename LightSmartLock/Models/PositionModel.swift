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
    
    // 新字段
    var address: String?
    var area: Double?
    var buildingId: String?
    var buildingName: String?
    var buildingNo: String?
    var cityId: String?
    var cityName: String?
    var floor: Int?
    var houseNum: String?
    var houseStruct: String?
    var id: String?
    var isHasBill: Bool!
    var isHasLock: Bool!
    var lockId: String?
    var snCode: String?
}
