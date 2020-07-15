//
//  TurnoverStatisticsDTO.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import HandyJSON

struct TurnoverStatisticsDTO: HandyJSON {
    var balance: Double?
    var expenseAmount: Double?
    var expenseCount: Int?
    var incomeAmount: Double?
    var incomeCount: Int?
}
