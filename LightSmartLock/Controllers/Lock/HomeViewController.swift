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
        $0.separatorStyle = .none
        $0.register(UINib(nibName: "AnimationHeaderView", bundle: nil), forCellReuseIdentifier: "AnimationHeaderView")
        $0.register(UINib(nibName: "HomeControlCell", bundle: nil), forCellReuseIdentifier: "HomeControlCell")
        $0.register(UINib.init(nibName: "HomeUnlockRecordHeader", bundle: nil), forCellReuseIdentifier: "HomeUnlockRecordHeader")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "门锁助手"
        
        bind()
        setupUI()
    }
    
    func setupUI() {
        noLockView.alpha = 0
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = ColorClassification.viewBackground.value
        view.backgroundColor = ColorClassification.viewBackground.value
    }
    
    func bind() {
        vm.isInstallLock.do(onNext: {[unowned self] (install) in
            self.hasLock(has: install)
        }).flatMapLatest {[unowned self] (_) in
            return Observable.zip(self.vm.userInScene, self.vm.lockInfo, self.vm.lockIOTInfo)
        }.subscribe(onNext: {[unowned self] (userInSence, lockInfo, lockIOTInfo) in
            LSLUser.current().userInScene = userInSence
            LSLUser.current().lockInfo = lockInfo
            LSLUser.current().lockIOTInfo = lockIOTInfo
            self.tableView.reloadData()
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
    }
    
    private func hasLock(has: Bool) {
        if has {
            noLockView.alpha = 0
            self.tabBarController?.tabBar.isHidden = false
            self.extendedLayoutIncludesOpaqueBars = false
        } else {
            noLockView.alpha = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        return UITableViewCell()
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
            return header
        }
        
        if section == 2 {
            let header = tableView.dequeueReusableCell(withIdentifier: "HomeUnlockRecordHeader") as! HomeUnlockRecordHeader
            return header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 280
        }
        if section == 1 {
            return 80
        }
        
        if section == 2 {
            return 40
        }
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}
