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
    
    let vm: HomeViewModeling = HomeViewModel()
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain).then {
        $0.tableFooterView = UIView(frame: .zero)
        $0.register(UINib(nibName: "AnimationHeaderView", bundle: nil), forCellReuseIdentifier: "AnimationHeaderView")
        $0.register(UINib(nibName: "HomeControlCell", bundle: nil), forCellReuseIdentifier: "HomeControlCell")
        $0.register(UINib(nibName: "HomeUnlockRecordHeader", bundle: nil), forCellReuseIdentifier: "HomeUnlockRecordHeader")
        $0.register(UINib(nibName: "UnlockRecordCell", bundle: nil), forCellReuseIdentifier: "UnlockRecordCell")
    }
    
    var dataSource: [UnlockRecordModel] = []
    
    private let synchronizeTaks = BluetoothSynchronizeTask()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .animationRestart, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        setupRightNavigationItems()
        observerNotification()
        synchronizeTaks.synchronizeTask()
        
    }
    
    func setupUI() {
        noLockView.alpha = 0
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorClassification.tableViewBackground.value
        view.backgroundColor = ColorClassification.viewBackground.value
        AppDelegate.changeStatusBarStyle(.lightContent)
    }
    
    func setupRightNavigationItems() {
        
        let lockSettingButton = UIButton(type: .custom)
        lockSettingButton.setImage(UIImage(named: "home_lock_setting_item"), for: UIControl.State())
        lockSettingButton.frame.size = CGSize(width: 32, height: 32)
        lockSettingButton.contentHorizontalAlignment = .right
        lockSettingButton.addTarget(self, action: #selector(self.gotoSettingVC), for: .touchUpInside)
        let settingItem = UIBarButtonItem(customView: lockSettingButton)
        
        let sceneButton = UIButton(type: .custom)
        sceneButton.contentHorizontalAlignment = .left
        sceneButton.addTarget(self, action: #selector(self.gotoMessageCenterVC), for: .touchUpInside)
        sceneButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        sceneButton.setImage(UIImage(named: "home_scene_icon"), for: UIControl.State())
        LSLUser.current().obScene.subscribe(onNext: { (scene) in
            if let name = scene?.sceneName {
                sceneButton.setTitle(
                    "  \(name)", for: UIControl.State())
            } else {
                sceneButton.setTitle(
                "  暂无数据", for: UIControl.State())
            }
            
        }).disposed(by: rx.disposeBag)
        
        let sceneItem = UIBarButtonItem(customView: sceneButton)
        
        self.navigationItem.leftBarButtonItems = [sceneItem]
        self.navigationItem.rightBarButtonItems = [settingItem]
    }
    
    func bind() {
        
        vm.isInstallLock.do(onNext: {[unowned self] (install) in
            self.hasLock(has: install)
        }).flatMapLatest {[unowned self] (_) in
            return self.vm.userInScene
        }.delaySubscription(0.5, scheduler: MainScheduler.instance).flatMapLatest {[unowned self] (userInScene) -> Observable<SmartLockInfoModel> in
            LSLUser.current().userInScene = userInScene
            return self.vm.lockInfo
        }.delaySubscription(0.5, scheduler: MainScheduler.instance).flatMapLatest {[unowned self] (lockInfo) -> Observable<IOTLockInfoModel> in
            LSLUser.current().lockInfo = lockInfo
            return self.vm.lockIOTInfo
        }.delaySubscription(0.5, scheduler: MainScheduler.instance).flatMapLatest {[unowned self] (IOTLockInfo) -> Observable<[UnlockRecordModel]> in
            LSLUser.current().lockIOTInfo = IOTLockInfo
            return self.vm.unlockRecord
        }.subscribe(onNext: {[unowned self] (list) in
            self.dataSource = list
            self.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func observerNotification() {
        
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .addLock:
                self?.hasLock(has: true)
            case .deleteLock, .deleteScene:
                self?.hasLock(has: false)
            default: break
            }
        }).disposed(by: rx.disposeBag)
        
        LSLUser.current().obScene.throttle(2, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (model) in
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
        let settingVC: HomeSettringController = ViewLoader.Storyboard.controller(from: "Home")
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
        
        switch indexPath.section {
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UnlockRecordCell", for: indexPath) as! UnlockRecordCell
            let data = dataSource[indexPath.row]
            cell.bind(data)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return dataSource.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "AnimationHeaderView") as! AnimationHeaderView
            
            header.bind(LSLUser.current().lockIOTInfo)
            return header
        }
        
        if section == 1 {
            let header = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell") as! HomeControlCell
            header.userButton.addTarget(self, action: #selector(self.gotoUserManagementVC), for: .touchUpInside)
            header.keyButton.addTarget(self, action: #selector(self.gotoPasswordManagementVC), for: .touchUpInside)
//            header.fingerButton.addTarget(self, action: #selector(self.gotoFingerManagementVC), for: .touchUpInside)
//            header.cardButton.addTarget(self, action: #selector(self.gotoCardManagementVC), for: .touchUpInside)
            return header
        }
        
        if section == 2 {
            let header = tableView.dequeueReusableCell(withIdentifier: "HomeUnlockRecordHeader") as! HomeUnlockRecordHeader
            header.checkMoreButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                
                guard let userCode = LSLUser.current().userInScene?.userCode else {
                    HUD.flash(.label("无法获取user code, 请稍后"), delay: 2)
                    return
                }
                let recordVC = RecordUnlockController(userCode: userCode)
                self?.navigationController?.pushViewController(recordVC, animated: true)
                
            }).disposed(by: header.disposeBag)
            return header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 280.0
        }
        if section == 1 {
            return 80.0
        }
        
        if section == 2 {
            return 40.0
        }
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return 64.0
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}
