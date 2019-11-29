//
//  Empty+UIViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

extension UIViewController: DZNEmptyDataSetSource {
    
    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "global_empty")
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "空空如也\n等等在看看吧~"
        let paragraphStyle = NSMutableParagraphStyle()
              paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): ColorClassification.textDescription.value,
                                                         NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                                                         NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let attributeString = NSAttributedString(string: text, attributes: attributes)
      
        
        return attributeString
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        switch self {
        default:
            return -20
        }
    }
}
