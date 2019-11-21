//
//  LoginViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ReactorKit
import PKHUD
import RxCocoa
import RxSwift
import Moya

class LoginViewController: UITableViewController, StoryboardView {
    
    typealias Reactor = LoginViewReactor
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var phoneContainerView: UIView!
    @IBOutlet weak var pwdContainerView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cell1: UITableViewCell!
    @IBOutlet weak var cell2: UITableViewCell!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.reactor = Reactor()
        
    }
    
    func bind(reactor: LoginViewReactor) {
        
        let phone = phoneTextField.rx.text.orEmpty.changed
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        let pwd = pwdTextField.rx.text.orEmpty.changed
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        Observable.combineLatest(phone, pwd).map(Reactor.Action.phonePasswordChanged)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        eyeButton.rx.tap.map {[unowned self] (_) -> Reactor.Action in
            let show = !self.eyeButton.isSelected
            self.eyeButton.isSelected = show
            return Reactor.Action.showPassword(show)
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        loginButton.rx.tap.map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.validationResult }.subscribe(onNext: {[weak self] (validation) in
            self?.loginButton.isEnabled = validation.isValid
            switch validation {
            case let .failed(error):
                if let e = error {
                    HUD.flash(.label(e.message), delay: 2)
                }
            default: break
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.loginError }
            .bind(to: PKHUD.sharedHUD.rx.showError)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.showPassword }.subscribe(onNext: {[weak self] (show) in
            self?.pwdTextField.isSecureTextEntry = !show
        }).disposed(by: disposeBag)
        
        
        reactor.state.map { $0.loginResult }.subscribe(onNext: { (result) in
            guard let success = result else {
                return
            }
            if success {
                NotificationCenter.default
                .post(name: .loginStateDidChange, object: true)
            }
            
        }).disposed(by: disposeBag)
    }
    
    func setupUI() {
        interactiveNavigationBarHidden = true
        
        tableView.backgroundColor = ColorClassification.viewBackground.value
        titleLabel.textColor = ColorClassification.textPrimary.value
        companyLabel.textColor = ColorClassification.textDescription.value
        
        phoneContainerView.setCircular(radius: 3)
        pwdContainerView.setCircular(radius: 3)
        loginButton.setCircular(radius: 3)
        
        eyeButton.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        eyeButton.setImage(UIImage(named: "login_eys_close"), for: .normal)
        
        pwdTextField.placeholderColor = #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
        phoneTextField.placeholderColor = #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
        
        phoneTextField.textColor = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
        pwdTextField.textColor = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
        
        cell1.backgroundColor = ColorClassification.viewBackground.value
        cell2.backgroundColor = ColorClassification.viewBackground.value

    }
    
}

