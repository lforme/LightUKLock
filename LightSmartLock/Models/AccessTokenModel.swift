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
    
    var access_token: String?
    var token_type: String?
    var expires_in: String?
    var refresh_token: String?
    var asclient_id: String?
    var userName: String?
}
