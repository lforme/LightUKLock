//
//  AccessTokenModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct AccessTokenModel: HandyJSON {
        
    // 新的字段
    var accessToken: String?
    var license: String?
    var tokenType: String?
    var userId: String?
}
