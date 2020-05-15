//
//  MyBillModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/15.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct MyBillModel: HandyJSON {
    
    struct ListItem: HandyJSON {
        var amount: Double?  // 费用金额
        var costCategoryId: String? // 费用类型id
        var costCategoryName: String? // 费用类型名称
        var cycleEndDate: String? // 账单结束周期
        var cycleStartDate: String? // 账单开始周期
        var id: String? //收款账号Id
    }
    
    var amount: Double?
    var assetId: String?
    var assetName: String?
    var billItemDTOList: [ListItem]?
    var billStatus: Int?
    var deadlineDate: String?
    var deadlineDays: Int?
    var id: String?
}



struct BillInfoDetail: HandyJSON {
    
    struct BillItemList: HandyJSON {
        var amount: Double?
        var costCategoryName: String?
        var cycleStartDate: String?
        var cycleEndDate: String?
    }
    
    struct BillPaymentItemList: HandyJSON {
        var createTime: String?
        var paymentSerial: String?
        var accountType: Int?
        var amount: Double?
    }
    
    var amountPaid: Double?
    var amountPayable: Double?
    var assetName: String?
    var billNumber: String?
    var billStatus: Int?
    var tenantName: String?
    var contractEndDate: String?
    var contractStartDate: String?
    
    var billItemDTOList: [BillItemList]?
    var billPaymentLogDTOList: [BillPaymentItemList]?
}
