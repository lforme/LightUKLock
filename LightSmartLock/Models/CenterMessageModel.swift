//
//  CenterMessageModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct CenterMessageModel: HandyJSON {
    
    var title: String?
    var content: String?
    var noticeType: Int?
    var createDate: String?
    var noticeLevel: Int?
}
