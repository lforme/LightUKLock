//
//  SelectLockTypeController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class SelectLockTypeController: UITableViewController, NavigationSettingStyle {
    
    enum SelectedType: Int, CustomStringConvertible {
        
        case kf100 = 0
        case kf100a
        
        var description: String {
            switch self {
            case .kf100:
                return "KF110"
            case .kf100a:
                return "KF100A"
            }
        }
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        title = "选择门锁类型"
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        guard let type = SelectedType(rawValue: indexPath.row) else {
            return
        }
        var lockInfo = SmartLockInfoModel()
        lockInfo.lockType = type.description
        lockInfo.UserCode = "01"
        lockInfo.AccountID = LSLUser.current().user?.accountID
        let initialLockVC: LockStartScanningController = ViewLoader.Storyboard.controller(from: "InitialLock")
        initialLockVC.lockInfo = lockInfo
        navigationController?.pushViewController(initialLockVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
