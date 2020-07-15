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
        
        guard let str = string, str.isNotEmpty else {
            return
        }
        
        if string?.hasPrefix("https") ?? false {
            guard let urlString = string else {
                return
            }
            
            self.kf.setImage(with: URL(string: urlString), placeholder: UIImage(named: "global_empty"))
            
        } else {
            guard let urlString = (ServerHost.shared.environment.host + str).encodeUrl() else {
                return
            }
            
            self.kf.setImage(with: URL(string: urlString), placeholder: UIImage(named: "global_empty"))
        }
    }
}
