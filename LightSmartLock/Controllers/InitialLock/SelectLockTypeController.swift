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
    
    enum AddKind {
        case newAdd
        case edited
    }
    
    var kind: AddKind!
    
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
        
        let initialLockVC: LockStartScanningController = ViewLoader.Storyboard.controller(from: "InitialLock")
        initialLockVC.kind = self.kind
        
        var lock = LockModel()
        
        if self.kind == .some(.edited) {
            lock.ladderAssetHouseId = LSLUser.current().scene?.ladderAssetHouseId
        }
        
        let array = Array(repeating: 0, count: 16).map { String($0) }.compactMap { $0 }
        let key = array.joined(separator:"")
        lock.bluetoothPwd = key
        LSLUser.current().lockInfo = lock
        lock.lockType = type.description
        initialLockVC.lockInfo = lock
        navigationController?.pushViewController(initialLockVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
