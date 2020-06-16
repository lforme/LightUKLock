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
    @IBOutlet weak var versionLabel: UILabel!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.reactor = Reactor()
        setupTitleLabelGesture()
    }
    
    func setupTitleLabelGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeEnvironment))
        tapGesture.numberOfTapsRequired = 10
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    func bind(reactor: LoginViewReactor) {
        
        let phone = phoneTextField.rx
            .text
            .orEmpty
            .changed
            .distinctUntilChanged()
        
        let pwd = pwdTextField.rx
            .text
            .orEmpty
            .changed
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
            .subscribe(onNext: { (e) in
                PKHUD.sharedHUD.rx.showAppError(e)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.showPassword }.subscribe(onNext: {[weak self] (show) in
            self?.pwdTextField.isSecureTextEntry = !show
        }).disposed(by: disposeBag)
        
        
        reactor.state.map { $0.loginResult }.subscribe(onNext: { (result) in
            print(result ?? "")
        }).disposed(by: disposeBag)
    }
    
    func setupUI() {
        
        phoneTextField.delegate = self
        
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
        
        versionLabel.text = ServerHost.shared.environment.description
        if ServerHost.shared.environment == .dev {
            versionLabel.text = ServerHost.shared.environment.description
        } else {
            versionLabel.text = nil
        }
        
    }
    
    @IBAction func registerTap(_ sender: UIButton) {
        let registerVC: RegisterForgetController = ViewLoader.Storyboard.controller(from: "Login")
        registerVC.styleType = .register
        registerVC.operateSuccessPhoneCall = {[weak self] (phoneNum) in
            self?.phoneTextField.text = phoneNum
            self?.phoneTextField.becomeFirstResponder()
        }
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func forgetPwdTap(_ sender: UIButton) {
        let forgetPwdVC: RegisterForgetController = ViewLoader.Storyboard.controller(from: "Login")
        forgetPwdVC.styleType = .forget
        forgetPwdVC.operateSuccessPhoneCall = {[weak self] (phoneNum) in
            self?.phoneTextField.text = phoneNum
        }
        self.navigationController?.pushViewController(forgetPwdVC, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = formattedNumber(number: newString)
        return false
    }
    
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX XXXX XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

extension LoginViewController {
    
    @objc func changeEnvironment() {
        self.showAlert(title: "开发模式", message: "切换开发环境", buttonTitles: ["开发环境", "线上环境", "取消"], highlightedButtonIndex: 2)
            .subscribe(onNext: { (index) in
                switch index {
                case 0:
                    ServerHost.shared.environment = .dev
                    HUD.flash(.label("已经切换到开发环境\nAPP即将关闭"), delay: 2, completion: { (_) in
                        exit(1)
                    })
                case 1:
                    ServerHost.shared.environment = .production
                    HUD.flash(.label("已经切换到线上环境\nAPP即将关闭"), delay: 2, completion: { (_) in
                        exit(1)
                    })
                case 2:
                    break
                default: break
                }
            }).disposed(by: rx.disposeBag)
    }
}
