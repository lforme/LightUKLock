//
//  MySettingViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD
import TZImagePickerController
import RxSwift
import IntentsUI

class MySettingViewController: UITableViewController, NavigationSettingStyle {
    
    enum CellType: Int {
        case avatar = 0
        case nickname = 1
        case password = 2
        case phone = 3
        case siri = 4
        case collectionAccount = 5
        case version = 6
        case privacyAndUse = 10
        case logout = 11
        
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var siriLabel: UILabel!
    
    let vm = MySettingViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账户设置"
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.tableView.backgroundColor = ColorClassification.tableViewBackground.value
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.avatar.clipsToBounds = true
        self.avatar.layer.cornerRadius = self.avatar.bounds.height / 2
    }
    
    func bind() {
        let shareInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
        shareInfo.map { $0?.userName }.bind(to: nameValue.rx.text).disposed(by: rx.disposeBag)
        shareInfo.map { $0?.avatar }.subscribe(onNext: {[weak self] (str) in
            self?.avatar.setUrl(str)
        }).disposed(by: rx.disposeBag)
        
        versionLabel.text = ServerHost.shared.environment.description
        siriLabel.text = LSLUser.current().hasSiriShortcuts ? "已设置" : "未设置"
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 8
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = CellType(rawValue: indexPath.row + indexPath.section * 10) else { return }
        switch type {
        case .avatar:
            uploadAvatarAction()
            
        case .nickname:
            changeNicknameAction()
            
        case .password:
            changePasswordAction()
            
        case .phone:
            changePhoneAction()
            
        case .logout:
            logoutAction()
            
        case .siri:
            setupSiriShortcuts()
            
        case .privacyAndUse:
            gotoPrivacyAndUse()
            
        case .collectionAccount:
            gotoCollectionAccount()
            
        default: break
        }
    }
}

extension MySettingViewController {
    
    func logoutAction() {
        showActionSheet(title: "确定要退出吗?", message: nil, buttonTitles: ["退出", "取消"], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                LSLUser.current().logout()
            }
        }
    }
    
    func uploadAvatarAction() {
        let imagePickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
        imagePickerVC?.needCircleCrop = true
        imagePickerVC?.didFinishPickingPhotosHandle = {[weak self] (photos, _, _)in
            guard let this = self else {
                return
            }
            if let image = photos?.first {
                this.avatar.image = image
                this.vm.changeUserAvatar(image).subscribe(onNext: { (user) in
                    LSLUser.current().user = user
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                }).disposed(by: this.rx.disposeBag)
            }
        }
        navigationController?.present(imagePickerVC!, animated: true, completion: nil)
    }
    
    func changeNicknameAction() {
        
        SingleInputController.rx.present(wiht: "修改昵称", saveTitle: "保存", placeholder: "请输入...").flatMapLatest(self.vm.changeNickname).subscribe(onNext: { (user) in
            LSLUser.current().user = user
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func changePasswordAction() {
        
        vm.verify().flatMapLatest {[weak self] (support, verify) -> Observable<String> in
            guard let this = self else {
                return .empty()
            }
            if verify {
                return ChangePasswordController.rx.present(from: this)
            }
            if !support {
                HUD.flash(.label("为了您的账号安全\n请开启手机密码验证"), delay: 2)
                return .empty()
            }
            return .empty()
        }.flatMapLatest {[weak self] (newPassword) -> Observable<UserModel> in
            guard let this = self else {
                return .empty()
            }
            return this.vm.changePassword(newPassword)
        }.subscribe(onNext: { (user) in
            HUD.flash(.label("密码修改成功"), delay: 2)
            LSLUser.current().user = user
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func changePhoneAction() {
        
        vm.verify().flatMapLatest {[weak self] (support, verify) -> Observable<String> in
            guard let this = self else {
                return .empty()
            }
            if verify {
                return ChangePhoneController.rx.present(from: this)
            }
            if !support {
                HUD.flash(.label("为了您的账号安全\n请开启手机密码验证"), delay: 2)
                return .empty()
            }
            return .empty()
        }.flatMapLatest {[weak self] (newPhone) -> Observable<UserModel> in
            guard let this = self else {
                return .empty()
            }
            return this.vm.changePhone(newPhone)
        }.subscribe(onNext: { (user) in
            HUD.flash(.label("电话修改成功"), delay: 2)
            LSLUser.current().user = user
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupSiriShortcuts() {
        if #available(iOS 12.0, *) {
            if LSLUser.current().hasSiriShortcuts {
                HUD.flash(.label("已设置过Siri开门"), delay: 2)
                let activity = NSUserActivity(activityType: "com.oldwhy.QuickSmartLock.sirisortcut.opendoor")
                print(activity.keywords)
            } else {
                let activity = NSUserActivity(activityType: "com.oldwhy.QuickSmartLock.sirisortcut.opendoor")
                activity.title = "请点击录音按钮, 试着对着它说开门指令, 例如: 开门 (当然你也可以录制个性指令: Open The Door) "
                activity.userInfo = ["speech" : "添加开门命令"]
                activity.isEligibleForSearch = true
                activity.isEligibleForPrediction = true
                activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.oldwhy.QuickSmartLock.sirisortcut.opendoor")
                view.userActivity = activity
                activity.becomeCurrent()
                
                let addSiriShortVersesVC = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
                addSiriShortVersesVC.delegate = self
                navigationController?.present(addSiriShortVersesVC, animated: true, completion: nil)
            }
            
        } else {
            HUD.flash(.label("iOS系统版本过低\n无法使用Siri开门"), delay: 2)
        }
    }
    
    func gotoCollectionAccount() {
        let collectionAccountVC: ReceivingAccountController = ViewLoader.Storyboard.controller(from: "Bill")
        navigationController?.pushViewController(collectionAccountVC, animated: true)
    }
    
    func gotoPrivacyAndUse() {
        let privacyAndUseVC: PrivacyAndUseController = ViewLoader.Storyboard.controller(from: "My")
        navigationController?.pushViewController(privacyAndUseVC, animated: true)
    }
}

@available(iOS 12.0, *)
extension MySettingViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        LSLUser.current().hasSiriShortcuts = true
        siriLabel.text = "已设置"
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
