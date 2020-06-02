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
    var billType: Int?
}



struct BillInfoDetail: HandyJSON {
    
    enum Payway: Int, HandyJSONEnum, CustomStringConvertible {
        case bank = 1
        case weixin = 2
        case alipay = 3
        case pos = 4
        case other = 999
        
        var description: String {
            switch self {
            case .bank:
                return "银行转账"
            case .weixin:
                return "微信支付"
            case .alipay:
                return "支付宝支付"
            case .pos:
                return "POS机"
            case .other:
                return "其他"
            }
        }
    }
    
    struct BillItemList: HandyJSON {
        var amount: Double?
        var costCategoryId: String?
        var costCategoryName: String?
        var cycleStartDate: String?
        var cycleEndDate: String?
    }
    
    struct BillPaymentItemList: HandyJSON {
        var createTime: String?
        var paymentSerial: String?
        var accountType: Payway?
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
    var gender: String?
    var age: Int?
    var deadlineDays: Int?
    var billType: Int?
    var billItemDTOList: [BillItemList]?
    var billPaymentLogDTOList: [BillPaymentItemList]?
}
