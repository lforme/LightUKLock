//
//  AppErrorDomain.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation


enum AppError: Error {
    
    case reason(String)
    
    var message: String {
        switch self {
        case .reason(let value):
            return value
        }
    }
}
