//
//  TenantContractDTO.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct TenantContractDTO: HandyJSON {
    var assetId: String?
    var contractNumber: String?
    var endDate: Date?
    var gender: String?
    var houseName: String?
    var id: String?
    var payMethod: String?
    var rental: Double?
    var startDate: Date?
    var tenantName: String?
    var tenantPhone: String?
    var tenantUserId: String?
}
