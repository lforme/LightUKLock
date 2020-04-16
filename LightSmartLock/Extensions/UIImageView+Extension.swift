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
        
        
      //  self.kf.setImage(with: <#T##Source?#>, placeholder: <#T##Placeholder?#>, options: <#T##KingfisherOptionsInfo?#>, progressBlock: <#T##DownloadProgressBlock?##DownloadProgressBlock?##(Int64, Int64) -> Void#>, completionHandler: <#T##((Result<RetrieveImageResult, KingfisherError>) -> Void)?##((Result<RetrieveImageResult, KingfisherError>) -> Void)?##(Result<RetrieveImageResult, KingfisherError>) -> Void#>)
    }
}
