//
//  StaticConst.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

let kLSRem = UIScreen.main.bounds.width / 375

extension NSNotification.Name {
    
    public static let loginStateDidChange = NSNotification.Name(rawValue: "loginStateDidChange")
    public static let statuBarDidChange = NSNotification.Name(rawValue: "statuBarDidChange")
    public static let refreshState = NSNotification.Name(rawValue: "refreshState")
    
}
