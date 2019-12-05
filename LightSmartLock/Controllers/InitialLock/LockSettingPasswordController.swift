//
//  LockSettingPasswordController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import CBPinEntryView
import PKHUD
import RxSwift
import RxCocoa

class LockSettingPasswordController: UIViewController {
    
    @IBOutlet weak var passwordInput: CBPinEntryView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var individualView: UIView!
    
    var lockInfo: SmartLockInfoModel!
    var vm: LockBindViewModel!
    fileprivate var adminPassword: String?
    fileprivate let privateKey = UUID().uuidString.components(separatedBy: "-").joined().prefix(16).description.lowercased()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定门锁"
        setupUI()
        bind()
    }
    
    func bind() {
        self.vm = LockBindViewModel.init(lockInfo: self.lockInfo)
    }
    
    func updateUI() {
        individualView.backgroundColor = ColorClassification.primary.value
    }
    
    func setupUI() {
        nextButton.setCircular(radius: nextButton.bounds.height / 2)
        nextButton.addTarget(self, action: #selector(self.nextTap), for: .touchUpInside)
        
        passwordInput.entryCornerRadius = 3
        passwordInput.entryBorderWidth = 1
        passwordInput.entryDefaultBorderColour = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.12)
        passwordInput.entryBorderColour = ColorClassification.primary.value
        passwordInput.entryEditingBackgroundColour = UIColor.white
        passwordInput.entryBackgroundColour = UIColor.white
        passwordInput.entryTextColour = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 1)
        passwordInput.delegate = self
        
    }
    
    @objc func nextTap() {
        guard let pwd = adminPassword, pwd.count == 6 else {
            HUD.flash(.label("请输入6位管理员密码"), delay: 2)
            return
        }
        self.vm.setAdiminPassword(pwd).flatMapLatest {[unowned self] (step) -> Observable<LockBindViewModel.Step> in
            return self.vm.checkVersionInfo()
        }.flatMapLatest { (step) -> Observable<LockBindViewModel.Step> in
            return self.vm.changeBroadcastName()
        }.flatMapLatest { (step) -> Observable<LockBindViewModel.Step> in
            return self.vm.setPrivateKey(self.privateKey)
        }.flatMapLatest { (step) -> Observable<LockBindViewModel.Step> in
            return self.vm.uploadToServer()
        }.subscribe(onNext: {[weak self] (step) in
            self?.updateUI()
            HUD.flash(.label(step.description), delay: 2)
            
            switch step {
            case let .uploadInfoToServer(sceneId):
                
                let positionVC: PositioEditingController = ViewLoader.Storyboard.controller(from: "Home")
                
                if self?.lockInfo.sceneID?.isEmpty ?? false {
                    var updateValue = LSLUser.current().scene
                    updateValue?.sceneID = sceneId
                    updateValue?.IsInstallLock = true
                    LSLUser.current().scene = updateValue
                    positionVC.editinType = .addNew
                } else {
                    positionVC.editinType = .modify
                }
                
                self?.navigationController?.pushViewController(positionVC, animated: true)
                
            default: break
            }
            
            }, onError: { (error) in
                HUD.flash(.label("门锁配置失败, 门锁已恢复出厂设置"), delay: 2)
                BluetoothPapa.shareInstance.factoryReset {[weak self] (_) in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
        }).disposed(by: rx.disposeBag)
    }
}

extension LockSettingPasswordController: CBPinEntryViewDelegate {
    
    func entryChanged(_ completed: Bool) {
        print("completed")
    }
    
    func entryCompleted(with entry: String?) {
        self.adminPassword = entry
    }
}
