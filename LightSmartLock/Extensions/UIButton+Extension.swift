//
//  UIButton+Extension.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    open override var isEnabled: Bool {
           didSet {
               alpha = isEnabled ? 1.0 : 0.4
           }
       }
}
