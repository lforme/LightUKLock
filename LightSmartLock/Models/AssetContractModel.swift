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
    var id: String?
}

struct AssetContractDetailModel: HandyJSON {
    
    struct TenantInfo: HandyJSON {
        var id: String?
        var idCard: String?
        var idCardFront: String?
        var idCardReverse: String?
        var phone: String?
        var userName: String?
    }
    
    struct FellowInfoList: HandyJSON {
        var userName: String?
        var phone: String?
    }
    
    var houseName: String?
    var tenantName: String?
    var tenantInfo: TenantInfo?
    var fellowInfoList: [FellowInfoList]?
    var startDate: String?
    var endDate: String?
    var payMethod: String?
    var rental: String?
    var deposit: String?
    var isIncrease: Bool?
    var isRemind: Bool?
    var isSeparate: Bool?
    var remark: String?
    var assetId: String?
}
