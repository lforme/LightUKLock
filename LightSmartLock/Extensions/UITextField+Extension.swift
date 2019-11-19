//
//  UITextField+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/7.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    
    private static let _placeholderColor = ObjectAssociation<UIColor>()
    
    @IBInspectable public var placeholderColor: UIColor? {
        get {
            return UITextField._placeholderColor[self]
        }
        set {
            UITextField._placeholderColor[self] = newValue
            guard let placeString = self.placeholder else {
                return
            }
            self.attributedPlaceholder =
                NSAttributedString(string: placeString, attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

fileprivate var limitInputLengthKey: Void?
extension UITextField {
    
    private static let _maxLengthWarningColor = ObjectAssociation<UIColor>()
    
    var maxLengthWarningColor: UIColor? {
        get {
            return UITextField._maxLengthWarningColor[self]
        }
        set {
            UITextField._maxLengthWarningColor[self] = newValue
        }
    }
    
    var maxLength: Int {
        get {
            guard let value = objc_getAssociatedObject(self, &limitInputLengthKey) as? Int else {
                return 0
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &limitInputLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let become = super.becomeFirstResponder()
        
        if maxLength > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: UITextField.textDidChangeNotification, object: nil)
        }
        
        return become
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let resign = super.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        return resign
    }
    
    
    @objc private func textFieldDidChange(notification: Notification) {
        
        guard let _ = notification.object as? UITextField,
            var texts = text,
            markedTextRange == nil else { return }
        // 禁止第一个字符输入空格或者换行
        if texts.count == 1, texts == " " || texts == "\n" {
            texts = ""
        }
        
        if maxLength != LONG_MAX,
            texts.count > maxLength {
            texts = texts.prefix(maxLength).description
            
            if let warningColor = maxLengthWarningColor {
                self.textColor = warningColor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.textColor = UIColor.flatRed()
                }
            }
        }
        text = texts
    }
}
