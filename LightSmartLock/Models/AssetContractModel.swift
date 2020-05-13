//
//  AssetContractModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/11.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct AssetContractModel: HandyJSON {
    var assetId: String?
    var tenantPhone: String?
    var tenantName: String?
    var houseName: String?
    var startDate: String?
    var endDate: String?
}
