//
//  UserDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class UserDetailController: UITableViewController, NavigationSettingStyle {
    
    enum SelectType: Int {
        case unlockRecord = 10
        case nickname = 20
        case delete = 30
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var hasBle: UIButton!
    @IBOutlet weak var hasCard: UIButton!
    @IBOutlet weak var hasMember: UIButton!
    @IBOutlet weak var hasDigital: UIButton!
    @IBOutlet weak var hasFinger: UIButton!
    
    
    var model: UserMemberListModel!
    var vm: UserDetailViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户详情"
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        hasDigital.set(image: UIImage(named: "home_user_digital_blue"), title: "数字密码", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasDigital.set(image: UIImage(named: "home_user_digtal_gray"), title: "数字密码", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasFinger.set(image: UIImage(named: "home_user_finger_blue"), title: "指纹密码", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasFinger.set(image: UIImage(named: "home_user_finger_gray"), title: "指纹密码", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasBle.set(image: UIImage(named: "home_user_ble_blue"), title: "蓝牙开锁", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasBle.set(image: UIImage(named: "home_user_ble_gray"), title: "蓝牙开锁", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasCard.set(image: UIImage(named: "home_user_card_blue"), title: "门禁卡", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasCard.set(image: UIImage(named: "home_user_card_gray"), title: "门禁卡", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasMember.set(image: UIImage(named: "home_user_member_blue"), title: "添加用户", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasMember.set(image: UIImage(named: "home_user_member_gray"), title: "添加用户", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        [hasMember, hasCard, hasBle, hasFinger, hasDigital].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.primary.value, for: .normal)
            btn?.setTitleColor(ColorClassification.textDescription.value, for: .disabled)
        }
    }
    
    func bind() {
        
        self.vm = UserDetailViewModel(userModel: model)
        
        nickname.text = model.nickname
        role.text = model.kinsfolkTag
        phone.text = model.phone
        
        guard let model = self.model else {
            return
        }
        if model.roleType == .some(.member) {
            hasMember.isEnabled = false
        } else {
            hasMember.isEnabled = true
        }
        hasCard.isEnabled = model.cardModel
        hasDigital.isEnabled = model.codeModel
        hasBle.isEnabled = model.bluetoothModel
        hasFinger.isEnabled = model.fingerprintModel
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.model else { return }
        guard let type = SelectType(rawValue: indexPath.row + indexPath.section * 10) else {
            return
        }
        
        switch type {
        case .unlockRecord:
            guard let lockId = LSLUser.current().scene?.ladderLockId else {
                return
            }
            let recordVC = RecordUnlockController(lockId: lockId, userId: model.id ?? "")
            self.navigationController?.pushViewController(recordVC, animated: true)
            
        case .nickname:
            SingleInputController.rx.present(wiht: "修改成员昵称", saveTitle: "保存", placeholder: model.nickname).flatMapLatest {[weak self] (newName) -> Observable<Bool> in
                guard let this = self else { return .just(false) }
                this.nickname.text = newName
                return this.vm.changeUserName(newName)
            }.subscribe(onNext: { (success) in
                if success {
                    HUD.flash(.label("修改昵称成功"), delay: 2)
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.editMember)
                } else {
                    HUD.flash(.label("修改失败, 请稍后再试"), delay: 2)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
            
        case .delete:
            Popups.showSelect(title: "请选择删除方式", indexTitleOne: "现场删除", IndexTitleTwo: "远程删除", contentA: "请在门锁附近(2-3米内)打开手机蓝牙删除用户，删除后立即生效", contentB: "请在网络信号通畅的地方删除，远程删除成员需云端同步到门锁，可能会存在信号延迟，请稍后在成员列表查看成员状态").map { UserDetailViewModel.DeleteWay(rawValue: $0)! }.flatMapLatest {[unowned self] (way) -> Observable<Bool> in
                return self.vm.deleteUser(way: way)
            }.subscribe(onNext: {[weak self] (succsee) in
                if succsee {
                    HUD.flash(.label("删除用户成功"), delay: 2)
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.editMember)
                    self?.navigationController?.popViewController(animated: true)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
