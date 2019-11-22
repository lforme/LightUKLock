//
//  RegisterForgetController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/22.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ReactorKit
import PKHUD
import RxCocoa
import RxSwift

class RegisterForgetController: UITableViewController, NavigationSettingStyle {
    
    @IBOutlet weak var cell1: UITableViewCell!
    @IBOutlet weak var cell2: UITableViewCell!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var getCodeButton: CountdownButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var containerB: UIView!
    @IBOutlet weak var containerC: UIView!
    
    let vm = RegisForgetViewModel()
    
    var operateSuccessPhoneCall: ((String?) -> Void)?
    
    enum StyleType {
        case register
        case forget
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.viewBackground.value
    }
    
    var styleType: StyleType = .register
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    func setupUI() {
        if styleType == .register {
            title = "快速注册"
        } else {
            title = "密码找回"
        }
        
        tableView.backgroundColor = ColorClassification.viewBackground.value
        
        containerA.setCircular(radius: 3)
        containerB.setCircular(radius: 3)
        containerC.setCircular(radius: 3)
        doneButton.setCircular(radius: 3)
        
        eyeButton.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        eyeButton.setImage(UIImage(named: "login_eys_close"), for: .normal)
        
        getCodeButton.setTitleColor(#colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68), for: .disabled)
        
        pwdTextField.placeholderColor = #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
        codeTextField.placeholderColor = #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
        phoneTextField.placeholderColor = #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
        
        phoneTextField.textColor = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
        codeTextField.textColor = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
        pwdTextField.textColor = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
        
        cell1.backgroundColor = ColorClassification.viewBackground.value
        cell2.backgroundColor = ColorClassification.viewBackground.value
    }
    
    func bind() {
        
        phoneTextField.rx.text.orEmpty.changed
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged().bind(to: vm.phone)
            .disposed(by: rx.disposeBag)
        
        
        codeTextField.rx.text.orEmpty.changed
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.code)
            .disposed(by: rx.disposeBag)
        
        pwdTextField.rx.text.orEmpty.changed
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.paassword)
            .disposed(by: rx.disposeBag)
        
        doneButton.rx.bind(to: vm.regisForgetAction) {[weak self] (_) -> RegisForgetViewModel.Input in
            return (self?.phoneTextField.text, self?.codeTextField.text, self?.pwdTextField.text)
        }
        
        getCodeButton.rx.bind(to: vm.getCodeAction) {[weak self] (btn) -> String? in
            btn.startCount()
            return self?.phoneTextField.text
        }
        
        let shareGetCodeErroe = vm.getCodeAction.errors.share(replay: 1, scope: .forever)
        shareGetCodeErroe.bind(to: PKHUD.sharedHUD.rx.showActionError).disposed(by: rx.disposeBag)
        shareGetCodeErroe.subscribe(onNext: {[weak self] (_) in
            self?.getCodeButton.reset()
        }).disposed(by: rx.disposeBag)
        
        vm.regisForgetAction.elements.subscribe(onNext: {[weak self] (isSuccess) in
            if isSuccess {
                HUD.flash(.label("成功"), delay: 2)
                self?.operateSuccessPhoneCall?(self?.phoneTextField.text)
                self?.navigationController?.popViewController(animated: true)
            } else {
                HUD.flash(.label("提交失败, 请稍后再试"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.regisForgetAction.errors.bind(to: PKHUD.sharedHUD.rx.showActionError).disposed(by: rx.disposeBag)
    }
}
