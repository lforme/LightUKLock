//
//  ChangePasswordController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Then
import RxCocoa
import RxSwift
import Action
import PKHUD

class ChangePasswordController: UITableViewController {
    
    @IBOutlet fileprivate weak var containerA: UIView!
    @IBOutlet fileprivate weak var containerB: UIView!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var textFieldFirst: UITextField!
    @IBOutlet fileprivate weak var textFieldConfirm: UITextField!
    @IBOutlet fileprivate weak var eyeButtonOne: UIButton!
    @IBOutlet fileprivate weak var eyeButtonTwo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改密码"
        setupUI()
    }
    
    func setupUI() {
        containerA.setCircular(radius: 3)
        containerB.setCircular(radius: 3)
        doneButton.setCircular(radius: 3)
        eyeButtonOne.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        eyeButtonOne.setImage(UIImage(named: "login_eys_close"), for: .normal)
        eyeButtonTwo.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        eyeButtonTwo.setImage(UIImage(named: "login_eys_close"), for: .normal)
        
        textFieldFirst.isSecureTextEntry = true
        textFieldConfirm.isSecureTextEntry = true
    }
    
    @IBAction private func eyeATap(_ sender: UIButton) {
        textFieldFirst.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction private func eyeBTap(_ sender: UIButton) {
        textFieldConfirm.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
}

extension Reactive where Base: ChangePasswordController {
    
    static func present(from: UIViewController) -> Observable<String> {
        return Observable<String>.create { (observer) -> Disposable in
            var changePwdVC: ChangePasswordController = ViewLoader.Storyboard.controller(from: "My")
            
            changePwdVC = changePwdVC.then { (vc) in
                vc.loadViewIfNeeded()
                let confirmAction = CocoaAction {
                    guard let textA = vc.textFieldFirst.text, let textB = vc.textFieldConfirm.text else {
                        HUD.flash(.label("请检查输入内容是否完整"), delay: 2)
                        return .empty()
                    }
                    
                    if textA == textB && !textA.isEmpty && !textB.isEmpty {
                        observer.onNext(textA)
                        observer.onCompleted()
                        return .empty()
                    } else {
                        HUD.flash(.label("请检查两次输入是否一致"), delay: 2)
                        return .empty()
                    }
                }
                vc.doneButton.rx.action = confirmAction
            }
            
            from.navigationController?.pushViewController(changePwdVC, animated: true)
            
            return Disposables.create {
                changePwdVC.navigationController?.popViewController(animated: true)
            }
        }
    }
}
