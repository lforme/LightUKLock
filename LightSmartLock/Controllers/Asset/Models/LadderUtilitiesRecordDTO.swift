//
//  LadderUtilitiesRecordDTO.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/9.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

class LadderUtilitiesRecordDTO: HandyJSON {
    var actualFee: Int?
    var code: String?
    var company: String?
    var currentGage: Int?
    var currentUse: Int?
    var guaranteeFee: Int?
    var isGuarantee: Int?
    var lastGage: Int?
    var price: Int?
    var recordDate: Date?
    var type: Int?
    
    required init() {
        
    }
}
