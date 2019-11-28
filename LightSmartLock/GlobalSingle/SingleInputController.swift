//
//  SingleInputController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

class SingleInputController: UIViewController {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var saveButton: UIButton!
    @IBOutlet fileprivate weak var backButton: UIButton!
    
    private var topTitle: String?
    private var saveTitle: String?
    private var placeholder: String?
    
    fileprivate convenience init(title: String?, saveTitle: String?, placeholder: String?) {
        self.init()
        loadViewIfNeeded()
        self.topTitle = title
        self.saveTitle = saveTitle
        self.placeholder = placeholder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension Reactive where Base: SingleInputController {
    
    static func present(wiht title: String? = nil, saveTitle: String? = "保存", placeholder: String? = "请输入...") -> Observable<String> {
        
        return Observable<String>.create { (observer) -> Disposable in
            let singleVC = SingleInputController(title: title, saveTitle: saveTitle, placeholder: placeholder).then { vc in
                
                vc.titleLabel.text = title
                vc.textField.placeholder = placeholder
                vc.saveButton.setTitle(saveTitle, for: UIControl.State())
                
                let dismissAction = CocoaAction {
                    vc.dismiss(animated: true, completion: nil)
                    observer.onCompleted()
                    return .empty()
                }
                
                vc.backButton.rx.action = dismissAction
                
                let confirmAction = CocoaAction {
                    guard let text = vc.textField.text else {
                        vc.dismiss(animated: true, completion: nil)
                        observer.onCompleted()
                        return .empty()
                    }
                    vc.dismiss(animated: true, completion: nil)
                    observer.onNext(text)
                    observer.onCompleted()
                    return .empty()
                }
                vc.saveButton.rx.action = confirmAction
            }
            
            if let currentVC = RootViewController.topViewController() {
                currentVC.present(singleVC, animated: true, completion: nil)
            } else {
                observer.onCompleted()
            }
            
            return Disposables.create {
                singleVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}
