//
//  TenantContractAndBillsDTO.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct TenantContractAndBillsDTO: HandyJSON {
    struct BillDTO: Codable {
        var amount: Double?
        var assetId: String?
        var assetName: String? 
        struct BillItemDTOList: Codable {
            var amount: Double?
            var costCategoryId: String?
            var costCategoryName: String?
            var cycleEndDate: Date?
            var cycleStartDate: Date?
            var id: String?
        }
        var billItemDTOList: [BillItemDTOList]?
        var billStatus: Int?
        var deadlineDate: Date?
        var deadlineDays: Int?
        var id: String?
    }
    var billDTO: BillDTO?
    var tenantContractDTO: TenantContractDTO?

}
