//
//  LockSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import Action
import RxSwift
import RxCocoa

class LockSettingController: UITableViewController {
    
    enum SelectType: Int {
        case sound = 0
        case firmwareUpdate = 1
        case reset = 10
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    
    let vm = LockSettingViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设备设置"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
        bind()
    }
    
    func bind() {
        
        self.vm.startConnected.subscribe(onNext: { (isConnected) in
            if isConnected {
                HUD.flash(.label("连接成功"), delay: 2)
            }
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        deleteButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let this = self else { return .empty() }
            return this.showActionSheet(title: "确定要删除门锁吗?", message: nil, buttonTitles: ["删除", "取消"], highlightedButtonIndex: 1)
        }.flatMapLatest {[weak self] (buttonIndex) -> Observable<Bool> in
            guard let this = self else { return .empty() }
            return this.vm.deleteLock(buttonIndex)
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                self?.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.editLock)
                var updateValue = LSLUser.current().scene
                updateValue?.ladderLockId = nil
                LSLUser.current().scene = updateValue
                LSLUser.current().lockInfo = nil
                
            } else {
                HUD.flash(.label("删除门锁失败"), delay: 2)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 20
        } else {
         return 8
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = SelectType(rawValue: indexPath.row + (indexPath.section * 10)) else {
            return
        }
        switch type {
        case .sound:
            let soundVC: SoundSettingController = ViewLoader.Storyboard.controller(from: "Home")
            soundVC.vm = self.vm
            navigationController?.pushViewController(soundVC, animated: true)
            
        case .firmwareUpdate:
            HUD.flash(.label("已是最新版本"), delay: 2)
            
        case .reset:
            let resetVC: ResetLockController = ViewLoader.Storyboard.controller(from: "Home")
            resetVC.vm = self.vm
            navigationController?.pushViewController(resetVC, animated: true)
        }
    }
}
