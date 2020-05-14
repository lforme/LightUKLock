//
//  BillLiquidationModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/14.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct BillLiquidationModel: HandyJSON {
    
    struct ListItem: HandyJSON {
        var amount: Double?
        var costCategoryId: String?
        var costInfo: String?
        var costName: String?
    }
    
    var billId: String?
    var id: String?
    var clearEndSate: String?
    var clearStartSate: String?
    var payableAmount: Double?
    var assetName: String?
    var tenantName: String?
    var phone: String?
    var billClearingItemDTOList: [ListItem]?
}
