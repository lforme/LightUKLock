//
//  BillLiquidationModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/14.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON
import RxCocoa
import RxSwift

struct BillLiquidationModel: HandyJSON {
    
    class ListItem: HandyJSON {
        required init() {}
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
    
    class BindModel {
        let amount = BehaviorRelay<String?>(value: nil)
        let costCategoryId: String
        let costInfo: String
        let costName: String
        
        init(costCategoryId: String, costInfo: String, costName: String, amount: Double) {
            self.amount.accept(String(amount))
            self.costCategoryId = costCategoryId
            self.costInfo = costInfo
            self.costName = costName
        }
        
        func convertTo() -> ListItem {
            let item = ListItem()
            item.amount = Double(amount.value ?? "0.00")
            item.costCategoryId = self.costCategoryId
            item.costInfo = self.costInfo
            item.costName = self.costName
            return item
        }
    }
}
