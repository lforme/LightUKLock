//
//  UIViewController+Extension.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    @discardableResult
    func createdRightNavigationItem(title: String?, font: UIFont? = UIFont.boldSystemFont(ofSize: 16), image: UIImage?, rightEdge: CGFloat = 10, color: UIColor = ColorClassification.textPrimary.value) -> UIButton {
        
        let fix = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fix.width = rightEdge - 15
        
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(color, for: .normal)
        btn.setTitleColor(color.withAlphaComponent(0.6), for: .disabled)
        btn.setTitleColor(color.withAlphaComponent(0.4), for: .highlighted)
        btn.setImage(image, for: UIControl.State())
        btn.sizeToFit()
        
        var frame = btn.frame
        let width = frame.width
        
        if width < 44 {
            fix.width = fix.width - (44 - width) / 2
            frame.size.width = 44
        }
        frame.size.height = 44
        btn.frame = frame
        
        let right = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItems = [fix, right]
        return btn
    }
    
    
    @discardableResult
    func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("OK")
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                if #available(iOS 9.0, *) {
                    alertController.preferredAction = action
                }
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    @discardableResult
    func showActionSheet(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("OK")
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                if #available(iOS 9.0, *) {
                    alertController.preferredAction = action
                }
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }
}

