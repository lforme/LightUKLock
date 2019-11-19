//
//  NavigationSettingStyle.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

public protocol NavigationSettingStyle: class {
    var backgroundColor: UIColor? { get }
    var itemColor: UIColor? { get }
    var titleFont: UIFont { get }
    var isLargeTitle: Bool { get }
}


extension NavigationSettingStyle {
    
    var titleFont: UIFont {
        if isLargeTitle {
            return UIFont.preferredFont(forTextStyle: .largeTitle)
        } else {
            return UIFont.systemFont(ofSize: 18, weight: .black)
        }
    }
    
    var isLargeTitle: Bool {
        return false
    }
    
    var itemColor: UIColor {
       return UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true)
    }
}
