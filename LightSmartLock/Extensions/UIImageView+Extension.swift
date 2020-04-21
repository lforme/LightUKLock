//
//  UIImageView+Extension.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/16.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    
    func setUrl(_ string: String?) {
        
        guard let str = string else {
            print("url不合法")
            return
        }
        
        
        guard let urlString = (ServerHost.shared.environment.host + str).encodeUrl() else {
            print("url不合法")
            return
        }
        
        self.kf.setImage(with: URL(string: urlString), placeholder: UIImage(named: "global_empty"))
    }
}
