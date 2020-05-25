//
//  HomeViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Lottie
import PKHUD
import RxSwift
import RxCocoa
import Then

class HomeViewController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var noLockView: UIView!
    let notiButton = UIButton(type: .custom)
    let lockSettingButton = UIButton(type: .custom)
    
    let vm: HomeViewModeling = HomeViewModel()
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain).then {
        $0.tableFooterView = UIView(frame: .zero)
        $0.register(UINib(nibName: "AnimationHeaderView", bundle: nil), forCellReuseIdentifier: "AnimationHeaderView")
        $0.register(UINib(nibName: "HomeControlCell", bundle: nil), forCellReuseIdentifier: "HomeControlCell")
        $0.register(UINib(nibName: "LeasedCell", bundle: nil), forCellReuseIdentifier: "LeasedCell")
    }
    
    //    private let synchronizeTaks = BluetoothSynchronizeTask()
    private let currentScene = BehaviorRelay<SceneListModel?>.init(value: nil)
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRightNavigationItems()
        observerNotification()
        //        synchronizeTaks.synchronizeTask()
    }
    
    func setupUI() {
        noLockView.alpha = 0
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorClassification.primary.value
        view.backgroundColor = ColorClassification.viewBackground.value
        AppDelegate.changeStatusBarStyle(.lightContent)
    }
    
    func setupRightNavigationItems() {
        
        
        lockSettingButton.setImage(UIImage(named: "home_lock_setting_item"), for: UIControl.State())
        lockSettingButton.frame.size = CGSize(width: 32, height: 32)
        lockSettingButton.contentHorizontalAlignment = .left
        lockSettingButton.addTarget(self, action: #selector(self.gotoSettingVC), for: .touchUpInside)
        let settingItem = UIBarButtonItem(customView: lockSettingButton)
        
        let notiButton = UIButton(type: .custom)
        notiButton.setImage(UIImage(named: "home_noti_navi"), for: UIControl.State())
        notiButton.frame.size = CGSize(width: 32, height: 32)
        notiButton.contentHorizontalAlignment = .left
        notiButton.addTarget(self, action: #selector(self.gotoMessageCenterVC), for: .touchUpInside)
        let notiItem = UIBarButtonItem(customView: notiButton)
        
        let sceneButton = UIButton(type: .custom)
        sceneButton.contentHorizontalAlignment = .right
        sceneButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sceneButton.setImage(UIImage(named: "home_scene_icon"), for: UIControl.State())
        
        sceneButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        LSLUser.current().obScene.subscribe(onNext: { [weak self](scene) in
            self?.currentScene.accept(scene)
            if let name = scene?.buildingName {
                sceneButton.setTitle(
                    "  \(name)", for: UIControl.State())
            } else {
                sceneButton.setTitle(
                    "  暂无数据", for: UIControl.State())
            }
            
        }).disposed(by: rx.disposeBag)
        
        let sceneItem = UIBarButtonItem(customView: sceneButton)
        
        self.navigationItem.leftBarButtonItems = [sceneItem]
        self.navigationItem.rightBarButtonItems = [settingItem, notiItem]
    }
    
    func bind() {
        
        vm.lockInfo?.subscribe(onNext: { (lock) in
            LSLUser.current().lockInfo = lock
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.homeInfo?.subscribe(onNext: {[weak self] (home) in
            guard let this = self else { return }
            let lockCell = this.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnimationHeaderView
            lockCell?.bind(openStatus: home.openStatus, onlineStatus: home.onlineStatus, power: LSLUser.current().lockInfo?.powerPercent)
            
            let tenantCell = this.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? LeasedCell
            if home.ladderOpenLockRecordVO?.userName.isNotNilNotEmpty ?? false {
                tenantCell?.unlocker.text = home.ladderOpenLockRecordVO?.userName
            } else {
                tenantCell?.unlocker.text = "未知解锁人员"
            }
            tenantCell?.unlockTime.text = home.ladderOpenLockRecordVO?.openTime
            this.tableView.reloadData()
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.isInstallLock.subscribe(onNext: { (install) in
            self.hasLock(has: install)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func observerNotification() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .deleteLock, .deleteScene:
                self?.hasLock(has: false)
            default: break
            }
        }).disposed(by: rx.disposeBag)
        
        LSLUser.current().obScene.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (model) in
            self?.bind()
        }).disposed(by: rx.disposeBag)
    }
    
    private func hasLock(has: Bool) {
        if has {
            noLockView.alpha = 0
            self.view.bringSubviewToFront(tableView)
        } else {
            noLockView.alpha = 1
            self.view.sendSubviewToBack(tableView)
        }
    }
    
    @objc func gotoMessageCenterVC() {
        let messageCenterVC: MessageCenterController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(messageCenterVC, animated: true)
    }
    
    @objc func gotoSettingVC() {
        let settingVC: HomeSettingController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc func gotoUserManagementVC() {
        let usermangeVC: UserManagementController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(usermangeVC, animated: true)
    }
    
    @objc func gotoPasswordManagementVC() {
        let passwordManageVC: PasswordManagementController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(passwordManageVC, animated: true)
    }
    
    @objc func gotoFingerManagementVC() {
        let fingerManageVC: FingerManageController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(fingerManageVC, animated: true)
    }
    
    @objc func gotoCardManagementVC() {
        let cardManageVC: CardManageController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(cardManageVC, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let animationCell = tableView.dequeueReusableCell(withIdentifier: "AnimationHeaderView") as! AnimationHeaderView
            
            animationCell.unlockButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                let openDoorVC: OpenDoorViewController = ViewLoader.Xib.controller()
                self?.present(openDoorVC, animated: true, completion: nil)
            }).disposed(by: animationCell.disposeBag)
            
            return animationCell
        case 2:
            let controlCell = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell") as! HomeControlCell
            controlCell.userButton.addTarget(self, action: #selector(self.gotoUserManagementVC), for: .touchUpInside)
            controlCell.keyButton.addTarget(self, action: #selector(self.gotoPasswordManagementVC), for: .touchUpInside)
            controlCell.messageButton.addTarget(self, action: #selector(self.gotoFingerManagementVC), for: .touchUpInside)
            controlCell.propertyButton.addTarget(self, action: #selector(self.gotoCardManagementVC), for: .touchUpInside)
            return controlCell
        case 1:
            let leasedCell = tableView.dequeueReusableCell(withIdentifier: "LeasedCell") as! LeasedCell
            leasedCell.assetName.text = LSLUser.current().scene?.buildingName ?? "正在加载..."
            leasedCell.assetAddress.text = LSLUser.current().scene?.buildingAdress ?? "正在加载..."
            
            leasedCell.recordDidSelected {[weak self] in
                guard let lockId = LSLUser.current().scene?.ladderLockId else {
                    HUD.flash(.label("无法获取user code, 请稍后"), delay: 2)
                    return
                }
                let recordVC = RecordUnlockController(lockId: lockId)
                self?.navigationController?.pushViewController(recordVC, animated: true)
            }
            
            leasedCell.propertyDidSelected {[weak self] in
                // 跳转资产页面
                print("tap")
                guard let assetId = self?.currentScene.value?.ladderAssetHouseId else { return }
                let vc: AssetDetailViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
                vc.assetId = assetId
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            return leasedCell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 340.0
        case 1:
            return 120.0
        case 2:
            return 200.0
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
}
