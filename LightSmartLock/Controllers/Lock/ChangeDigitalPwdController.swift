//
//  ChangeDigitalPwdController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import CBPinEntryView
import RxCocoa
import RxSwift
import PKHUD

class ChangeDigitalPwdController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    var oldPassword: String!
    @IBOutlet weak var passwordInput: CBPinEntryView!
    @IBOutlet weak var desLabel: UILabel!
    
    var vm: DigitalChangePwdViewModel!
    var newPassword: String?
    var saveButton: UIButton!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "永久密码"
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func setupNavigationRightItem() {
        saveButton = createdRightNavigationItem(title: "完成", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 12, color: .white)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        
        passwordInput.entryCornerRadius = 3
        passwordInput.entryBorderWidth = 1
        passwordInput.entryDefaultBorderColour = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.12)
        passwordInput.entryBorderColour = ColorClassification.primary.value
        passwordInput.entryEditingBackgroundColour = UIColor.white
        passwordInput.entryBackgroundColour = UIColor.white
        passwordInput.entryTextColour = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 1)
        passwordInput.delegate = self
    }
    
    func bind() {
        
        self.vm = DigitalChangePwdViewModel(oldPassword: oldPassword)
        self.vm.modifyType.subscribe(onNext: {[weak self] (type) in
            switch type {
            case .bluetooth:
                self?.desLabel.text = "已选择 现场修改"
            case .cloudServer:
                self?.desLabel.text = "已选择 远程修改"
            }
        }).disposed(by: rx.disposeBag)
        
        Popups.showSelect(title: "选择修改方式", indexTitleOne: "现场修改", IndexTitleTwo: "远程修改", contentA: "请在门锁附近(2-3米内)打开手机蓝牙修改，修改完成后密码立即生效", contentB: "请在网络信号通畅的地方修改，远程修改密码需云端同步到门锁，可能会存在信号延迟，请稍后在数字密码中查看密码状态").delaySubscription(1, scheduler: MainScheduler.instance).map { (index) -> DigitalChangePwdViewModel.ModifyType in
            return DigitalChangePwdViewModel.ModifyType(rawValue: index)!
        }.bind(to: vm.modifyType).disposed(by: rx.disposeBag)
        
        saveButton.rx.bind(to: vm.saveAction) {[weak self] (_) -> String in
            
            return self?.newPassword ?? ""
        }
        
        vm.saveAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.saveAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                HUD.flash(.label("修改成功"), delay: 2)
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.changeDigitalPwd(self?.newPassword))
                self?.navigationController?.popViewController(animated: true)
            } else {
                HUD.flash(.label("修改失败"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
    }
}

extension ChangeDigitalPwdController: CBPinEntryViewDelegate {
    
    func entryChanged(_ completed: Bool) {
        print("completed")
    }
    
    func entryCompleted(with entry: String?) {
        self.newPassword = entry
        self.vm.newPassword.accept(entry)
    }
}
