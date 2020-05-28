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
    var billDTO: MyBillModel?
    var tenantContractDTO: TenantContractDTO?
    var roleType: Int?
}
