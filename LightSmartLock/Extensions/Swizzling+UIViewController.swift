//
//  Swizzling+UIViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit


extension AppDelegate {
    override open var next: UIResponder? {
        UIViewController.awake
        return super.next
    }
}

fileprivate var interactiveNavigationBarHiddenAssociationKey: UInt8 = 0
extension UIViewController {
    
    @IBInspectable public var interactiveNavigationBarHidden: Bool {
        get {
            var associateValue = objc_getAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey)
            if associateValue == nil {
                associateValue = false
            }
            return associateValue as! Bool;
        }
        set {
            objc_setAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate static let awake : Void  = {
        replaceInteractiveMethods()
        return
    }()
    
    fileprivate static func replaceInteractiveMethods() {
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(UIViewController.vc_interactiveViewWillAppear))!)
        
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewDidLoad))!,
            class_getInstanceMethod(self, #selector(UIViewController.vc_swizzled_viewDidLoad))!
        )
    }
    
    @objc func vc_interactiveViewWillAppear(_ animated: Bool) {
        vc_interactiveViewWillAppear(animated)
        navigationController?.setNavigationBarHidden(interactiveNavigationBarHidden, animated: animated)
    }
    
    @objc func vc_swizzled_viewDidLoad() {
        vc_swizzled_viewDidLoad()
        
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.contentHorizontalAlignment = .leading
            let img = UIImage(named: "back_arrow")
            
            button.setImage(img, for: .normal)
            button.contentMode = .left
            button.addTarget(self, action: #selector(leftNavigationItemAction), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    @objc func leftNavigationItemAction() {
        let parentVC = self.navigationController?.popViewController(animated: true)
        guard let p = parentVC else {
            return
        }
        p.dismiss(animated: true, completion: nil)
    }
}
