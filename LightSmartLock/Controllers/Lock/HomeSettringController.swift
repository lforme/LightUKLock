//
//  HomeSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class HomeSettingController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    enum SeletType: Int {
        case lockSetting = 0
        case lockInfo
        case position
        case privacyPolicy = 10
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "设置"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SeletType(rawValue: indexPath.row + (indexPath.section * 10)) else {
            return
        }
        
        switch type {
        case .lockSetting:
            let lockSettingVC: LockSettingController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockSettingVC, animated: true)
            
        case .lockInfo:
            let lockInfoVC: LockInfoController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockInfoVC, animated: true)
            
        case .position:
            let positionVC: PositioEditingController = ViewLoader.Storyboard.controller(from: "Home")
            positionVC.id = LSLUser.current().scene?.ladderAssetHouseId
            navigationController?.pushViewController(positionVC, animated: true)
            
        case .privacyPolicy:
            let url = ServerHost.shared.environment.host + "/share/policies_of_privacy.html"
            let privacyPolicyVC =  LSLWebViewController(navigationTitile: "使用条款", webUrl: url)
            navigationController?.pushViewController(privacyPolicyVC, animated: true)
        }
    }
}
