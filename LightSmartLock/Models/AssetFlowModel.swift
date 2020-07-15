//
//  AssetFlowModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/11.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct AssetFlowModel: HandyJSON {

    struct TurnoverDTO: HandyJSON {
        var amount: Double!
        var costName: String?
        var payTime: String?
        var payerName: String?
    }
    
    var balance: Double!
    var yearAndMonth: String?
    var expense: Double!
    var income: Double!
    var turnoverDTOList: [TurnoverDTO]?
}


struct AddFlowParameter: HandyJSON {
    var amount: String?
    var costCategoryId: String?
    var turnoverType: Int?
    var costName: String?
}


struct FeesKindModel: HandyJSON {
    var categoryCode: String?
    var icon: String?
    var id: String?
    var isCustomized: Bool!
    var name: String?
}
