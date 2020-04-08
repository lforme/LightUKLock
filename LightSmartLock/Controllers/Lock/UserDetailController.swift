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
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var cell1: UITableViewCell!
    
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var cell2Label: UILabel!
    @IBOutlet weak var cell3Label: UILabel!
    @IBOutlet weak var cell4Label: UILabel!
    
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
        
        if cell1.responds(to: #selector(setter: cell1.separatorInset)) {
            cell1.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        }
    }
    
    func bind() {
        
        self.vm = UserDetailViewModel(userModel: model)
        
        nickname.text = model.nickname
        role.text = model.roleType.description
        phone.text = model.phone
        
        guard let model = self.model else {
            return
        }
        
        if LSLUser.current().user?.accountID == model.lockUserAccount && model.roleType == .some(.superAdmin) {
            cell2Label.text = "永久密码"
            cell3Label.text = "指纹"
            cell4Label.text = "门卡"
        } else {
            cell2Label.text = "修改用户名称"
            cell3Label.text = "删除"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let model = self.model else {
            return 0
        }
        if LSLUser.current().user?.accountID == model.id && model.roleType == .some(.superAdmin) {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.model else { return }
        
        if LSLUser.current().user?.accountID == model.id && model.roleType == .some(.superAdmin) {
            
            switch indexPath.row {
            case 1:
                print("密码管理")
                let passwordManageVC: PasswordManagementController = ViewLoader.Storyboard.controller(from: "Home")
                navigationController?.pushViewController(passwordManageVC, animated: true)
            case 2:
                print("指纹管理")
                let fingerManageVC: FingerManageController = ViewLoader.Storyboard.controller(from: "Home")
                navigationController?.pushViewController(fingerManageVC, animated: true)
            case 3:
                print("门卡管理")
                let cardManageVC: CardManageController = ViewLoader.Storyboard.controller(from: "Home")
                navigationController?.pushViewController(cardManageVC, animated: true)
            default:
                break
            }
            
        } else {
            
            switch indexPath.row {
            case 1:
                print("修改用户名称")
                SingleInputController.rx.present(wiht: "修改成员昵称", saveTitle: "保存", placeholder: model.nickname).flatMapLatest {[weak self] (newName) -> Observable<Bool> in
                    guard let this = self else { return .just(false) }
                    this.nickname.text = newName
                    return this.vm.changeUserName(newName)
                }.subscribe(onNext: { (success) in
                    if success {
                        HUD.flash(.label("修改昵称成功"), delay: 2)
                    } else {
                        HUD.flash(.label("修改失败, 请稍后再试"), delay: 2)
                    }
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                }).disposed(by: rx.disposeBag)
                
            case 2:
                print("删除用户")
                Popups.showSelect(title: "请选择删除方式", indexTitleOne: "现场删除", IndexTitleTwo: "远程删除", contentA: "请在门锁附近(2-3米内)打开手机蓝牙删除用户，删除后立即生效", contentB: "请在网络信号通畅的地方删除，远程删除成员需云端同步到门锁，可能会存在信号延迟，请稍后在成员列表查看成员状态").map { UserDetailViewModel.DeleteWay(rawValue: $0)! }.flatMapLatest {[unowned self] (way) -> Observable<Bool> in
                    return self.vm.deleteUser(way: way)
                }.subscribe(onNext: { (succsee) in
                    if succsee {
                        HUD.flash(.label("删除用户成功"), delay: 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {[weak self] in
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                }).disposed(by: rx.disposeBag)
                
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
