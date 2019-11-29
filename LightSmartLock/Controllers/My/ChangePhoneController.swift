//
//  ChangePhoneController.swift
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

class ChangePhoneController: UITableViewController {
    
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var codeButton: CountdownButton!
    @IBOutlet weak var codeTextfield: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var containerB: UIView!
    
    fileprivate var codeVerify = false
    
    var getCodeAction: Action<String?, Bool>!
    var doneAction: Action<(String?, String?), String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改手机"
        setupUI()
        setupCodeButtonAction()
    }
    
    func setupUI() {
        containerA.setCircular(radius: 3)
        containerB.setCircular(radius: 3)
        doneButton.setCircular(radius: 3)
    }
    
    private func setupCodeButtonAction() {
        
        self.getCodeAction = Action<String?, Bool>(workFactory: { (str) -> Observable<Bool> in
            guard let textA = str, textA.count == 11 else {
                return .error(AppError.reason("请填写正确手机号码"))
            }
            
            return AuthAPI.requestMapBool(.MSMFetchCode(phone: textA))
        })
        
        self.codeButton.rx.bind(to: self.getCodeAction) {[weak self] (btn) -> String? in
            btn.startCount()
            return self?.phoneTextfield.text
        }
        
        self.getCodeAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    fileprivate func setupDoneAction() -> Observable<String> {
        self.doneAction = Action<(String?, String?), String>(workFactory: { (phone, code) -> Observable<String> in
            
            guard let p = phone, let c = code, p.count == 11, c.count > 0 else {
                return .error(AppError.reason("请检查输入是否完整"))
            }
            
            return AuthAPI.requestMapBool(.validatePhoneCode(phone: p, code: c)).map { (isValidate) -> String in
                if isValidate {
                    return p
                } else {
                    throw AppError.reason("验证码验证失败")
                }
            }
        })
        
        self.doneButton.rx.bind(to: self.doneAction) {[weak self] (_) -> (String?, String?) in
            return (self?.phoneTextfield.text, self?.codeTextfield.text)
        }
        
        self.doneAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        
        return self.doneAction.elements
    }
}

extension Reactive where Base: ChangePhoneController {
    
    static func present(from: UIViewController) -> Observable<String> {
        
        let changePhoneVC: ChangePhoneController = ViewLoader.Storyboard.controller(from: "My")
        changePhoneVC.loadViewIfNeeded()
        
        from.navigationController?.pushViewController(changePhoneVC, animated: true)
        
        return changePhoneVC.setupDoneAction().do(onNext: { (code) in
            from.navigationController?.popViewController(animated: true)
        })
    }
}
