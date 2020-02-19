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
        $0.register(UINib(nibName: "LeasedCell", bundle: nil), forCellReuseIdentifier: "LeasedCell")
        $0.register(UINib(nibName: "UnlockRecordCell", bundle: nil), forCellReuseIdentifier: "UnlockRecordCell")
    }
    
    var dataSource: [UnlockRecordModel] = []
    
    private let synchronizeTaks = BluetoothSynchronizeTask()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRightNavigationItems()
        observerNotification()
        synchronizeTaks.synchronizeTask()
        setupaAnimationObserver()
    }
    
    func setupaAnimationObserver() {
        UIApplication.shared.rx
            .didBecomeActive
            .subscribe(onNext: {[weak self] _ in
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func restartAnimation() {
        let animationView = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnimationHeaderView
        animationView?.animationView.play()
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
        tableView.backgroundColor = ColorClassification.viewBackground.value
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
        
        switch indexPath.row {
        case 0:
            let animationCell = tableView.dequeueReusableCell(withIdentifier: "AnimationHeaderView") as! AnimationHeaderView
            
            animationCell.bind(LSLUser.current().lockIOTInfo)
            return animationCell
        case 1:
            let controlCell = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell") as! HomeControlCell
            controlCell.userButton.addTarget(self, action: #selector(self.gotoUserManagementVC), for: .touchUpInside)
            controlCell.keyButton.addTarget(self, action: #selector(self.gotoPasswordManagementVC), for: .touchUpInside)
            return controlCell
        case 2:
            let LeasedCell = tableView.dequeueReusableCell(withIdentifier: "LeasedCell") as! LeasedCell
            return LeasedCell
            
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
            return 100.0
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}
