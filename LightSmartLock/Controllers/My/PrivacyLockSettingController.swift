//
//  PrivacyLockSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PrivacyLockSettingController: UITableViewController, NavigationSettingStyle {
    
    @IBOutlet weak var verifySwitch: UISwitch!
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "隐私设置"
        setupUI()
        bind()
    }
    
    func bind() {
        verifySwitch.isOn = LSLUser.current().hasVerificationLock
        
        verifySwitch.rx.isOn.subscribe(onNext: { (isOn) in
            LSLUser.current().hasVerificationLock = isOn
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8
    }
}
