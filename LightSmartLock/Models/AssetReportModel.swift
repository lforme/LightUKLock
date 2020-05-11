//
//  AssetReportModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct AssetReportModel: HandyJSON {
    var costCategoryId: String?
    var costCategoryName: String?
    var costType: Int!  //费用类型 1:收入 -1:支出
    var count: Int!  //费用总笔数
    var paidCount: Int! // 到款笔数
    var ratio: Int! // 资金占比
    var totalAmount: Int! // 总收入金额
}


struct ReportFeesModel: HandyJSON {
    var costCategoryName: String?
    var userName: String?
    var cycleStartDate: String?
    var cycleEndDate: String?
    var billType: Int! //账单类型（1：收款 -1 付款账单）
    var amount: Double?
}
