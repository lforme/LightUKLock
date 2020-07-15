//
//  VerficationIDController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import LocalAuthentication
import RxSwift
import RxCocoa
import PKHUD

class VerficationIDController: UIViewController {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var verificationButton: UIButton!
    @IBOutlet weak var useOtherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupObserver()
    }
    
    func setupObserver() {

        NotificationCenter.default.rx.notification(.tokenExpired)
            .subscribe(onNext: {[weak self] (notiObjc) in
            self?.dismiss(animated: false, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
                
        let shareUserInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
        
        shareUserInfo
            .map { $0?.avatar }
            .subscribe(onNext: {[weak self] (urlString) in
                self?.userAvatar.setUrl(urlString)
            }).disposed(by: rx.disposeBag)
        
        shareUserInfo
            .map {
                guard var phone = $0?.phone else {
                    return ""
                }
                let start = phone.index(phone.startIndex, offsetBy: 3)
                let end = phone.index(phone.startIndex, offsetBy: 3 + 4)
                phone.replaceSubrange(start..<end, with: "****")
                return phone
        }
        .bind(to: phone.rx.text)
        .disposed(by: rx.disposeBag)
    }
    
    @IBAction func verifyTap(_ sender: UIButton) {
        
        VerficationIDController.verify()
            .subscribe(onNext: {[weak self] (isSupport, isVerify) in
                if isVerify {
                    self?.dismiss(animated: true, completion: nil)
                }
                if !isSupport {
                    HUD.flash(.label("请到手机设置中开启密码锁"), delay: 2)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func useOtherAccountTap(_ sender: UIButton) {
        self.showAlert(title: "确定要使用其他账号登陆吗", message: nil, buttonTitles: ["确定", "取消"], highlightedButtonIndex: 1)
            .subscribe(onNext: { (buttonIndex) in
                if buttonIndex == 0 {
                    LSLUser.current().logout()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}


extension VerficationIDController {
    
    static func verify() -> Observable<(isSupport: Bool, isVerify: Bool)> {
        return Observable.create { (observer) -> Disposable in
            let laContext = LAContext()
            laContext.localizedFallbackTitle = "验证失败"
            laContext.localizedCancelTitle = "取消验证"
            var error : NSError?
            let support = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if support {
                laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证您的身份") { (success, er) in
                    DispatchQueue.main.async {
                        if let e = er {
                            print(e.localizedDescription)
                            observer.onNext((isSupport: true, isVerify: false))
                            observer.onCompleted()
                        } else {
                            observer.onNext((isSupport: true, isVerify: true))
                            observer.onCompleted()
                        }
                    }
                }
            } else {
                observer.onNext((isSupport: false, isVerify: false))
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
}
