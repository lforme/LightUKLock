//
//  UserManagementController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import MJRefresh
import UIKit
import PKHUD
import Kingfisher

class UserManagementController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let vm = UserManagementViewModel()
    var dataSource: [UserMemberListModel] = []
    
    lazy var addMemberButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "home_member_add"), for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        return btn
    }()
    
    deinit {
        addMemberButton.removeFromSuperview()
        print("\(self) deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addMemberButton.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(-20)
            maker.right.equalToSuperview().offset(-20)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.sendSubviewToBack(addMemberButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.bringSubviewToFront(addMemberButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户管理"
        setupUI()
        setupTableviewRefresh()
        bind()
        observerNotification()
    }
    
    func observerNotification() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .editMember:
                self?.tableView.mj_header?.beginRefreshing()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupTableviewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.vm.refresh()
        })
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.vm.loadMore()
        })
        footer.setTitle("", for: .idle)
        tableView.mj_footer = footer
    }
    
    func bind() {
        vm.refreshStatus.subscribe(onNext: {[weak self] (status) in
            switch status {
            case .endFooterRefresh:
                self?.tableView.mj_footer?.endRefreshing()
            case .endHeaderRefresh:
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.resetNoMoreData()
            case .noMoreData:
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            case .none:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
                    self?.tableView.mj_header?.beginRefreshing()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        vm.list.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        
        self.navigationController?.view.addSubview(addMemberButton)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserManagementAdminCell", for: indexPath) as! UserManagementAdminCell
            let currentUserId = LSLUser.current().user?.id
            let data =  dataSource.filter { $0.id == currentUserId }.first
            cell.bind(data)
            cell.hasDigital.addTarget(self, action: #selector(gotoDigitalPassword), for: .touchUpInside)
            cell.hasCard.addTarget(self, action: #selector(gotoCard), for: .touchUpInside)
            cell.hasBle.addTarget(self, action: #selector(gotoBleOpenTheDoor), for: .touchUpInside)
            cell.hasFinger.addTarget(self, action: #selector(gotoFingerPassword), for: .touchUpInside)
            cell.hasMemberShip.addTarget(self, action: #selector(gotoAddUser), for: .touchUpInside)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserManagementCell", for: indexPath) as! UserManagementCell
        let data = dataSource[indexPath.row]
        
        cell.nickname.text = data.nickname
        cell.role.text = data.kinsfolkTag
        cell.avatar.setUrl(data.avatar)
        switch data.state {
        case 0, 2, 3:
            cell.synchronizedStart(true)
        default:
            cell.synchronizedStart(false)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let data = dataSource[indexPath.row]
            let userDetailVC: UserDetailController = ViewLoader.Storyboard.controller(from: "Home")
            userDetailVC.model = data
            navigationController?.pushViewController(userDetailVC, animated: true)
        }
    }
    
    @objc func gotoDigitalPassword() {
        let vm = PasswordManagementViewModel()
        let digitalPwdVC: DigitalPwdDetailController = ViewLoader.Storyboard.controller(from: "Home")
        digitalPwdVC.vm = vm
        vm.refresh()
        navigationController?.pushViewController(digitalPwdVC, animated: true)
    }
    
    @objc func gotoFingerPassword() {
        let passwordVC: PasswordSequenceController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(passwordVC, animated: true)
    }
    
    @objc func gotoBleOpenTheDoor() {
        let openDoorVC: OpenDoorViewController = ViewLoader.Xib.controller()
        self.present(openDoorVC, animated: true, completion: nil)
    }
    
    @objc func gotoCard() {
        let passwordVC: PasswordSequenceController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(passwordVC, animated: true)
    }
    
    @objc func gotoAddUser() {
        addUser()
    }
    
    @objc private func addUser() {
        let addUserVC: AddUserController = ViewLoader.Storyboard.controller(from: "Home")
        self.navigationController?.pushViewController(addUserVC, animated: true)
    }
}

class UserManagementAdminCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var hasDigital: UIButton!
    @IBOutlet weak var hasFinger: UIButton!
    @IBOutlet weak var hasBle: UIButton!
    @IBOutlet weak var hasCard: UIButton!
    @IBOutlet weak var hasMemberShip: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bind(_ model: UserMemberListModel?) {
        avatar.setUrl(model?.avatar)
        name.text = model?.nickname
        role.text = model?.roleType.description
        if model?.roleType == .some(.member) {
            hasMemberShip.isEnabled = false
        } else {
            hasMemberShip.isEnabled = true
        }
        hasCard.isEnabled = model?.cardModel ?? false
        hasDigital.isEnabled = model?.codeModel ?? false
        hasBle.isEnabled = model?.bluetoothModel ?? false
        hasFinger.isEnabled = model?.fingerprintModel ?? false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        bgView.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        avatar.setCircular(radius: avatar.bounds.height / 2)
        
        hasDigital.set(image: UIImage(named: "home_user_digital_blue"), title: "数字密码", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasDigital.set(image: UIImage(named: "home_user_digtal_gray"), title: "数字密码", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasFinger.set(image: UIImage(named: "home_user_finger_blue"), title: "指纹密码", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasFinger.set(image: UIImage(named: "home_user_finger_gray"), title: "指纹密码", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasBle.set(image: UIImage(named: "home_user_ble_blue"), title: "蓝牙开锁", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasBle.set(image: UIImage(named: "home_user_ble_gray"), title: "蓝牙开锁", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasCard.set(image: UIImage(named: "home_user_card_blue"), title: "门禁卡", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasCard.set(image: UIImage(named: "home_user_card_gray"), title: "门禁卡", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        hasMemberShip.set(image: UIImage(named: "home_user_member_blue"), title: "添加用户", titlePosition: .bottom, additionalSpacing: 30, state: .normal)
        hasMemberShip.set(image: UIImage(named: "home_user_member_gray"), title: "添加用户", titlePosition: .bottom, additionalSpacing: 30, state: .disabled)
        
        [hasMemberShip, hasCard, hasBle, hasFinger, hasDigital].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.primary.value, for: .normal)
            btn?.setTitleColor(ColorClassification.textDescription.value, for: .disabled)
        }
    }
}

class UserManagementCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var sysIcon: UIImageView!
    @IBOutlet weak var synLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        synLabel.isHidden = true
        sysIcon.isHidden = true
        avatar.setCircular(radius: avatar.bounds.height / 2)
        selectionStyle = .none
    }
    
    func synchronizedStart(_ start: Bool) {
        if start {
            synLabel.isHidden = false
            sysIcon.isHidden = false
            let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = Double.pi * 2
            rotation.duration = 3
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            sysIcon.layer.add(rotation, forKey: "rotationAnimation")
        } else {
            synLabel.isHidden = true
            sysIcon.isHidden = true
            sysIcon.layer.removeAnimation(forKey: "rotationAnimation")
            self.accessoryType = .disclosureIndicator
        }
    }
}
