//
//  PasswordManagementController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate

class PasswordManagementController: UITableViewController, NavigationSettingStyle {
    
    enum SelectType: Int {
        case multiple
        case temporary
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var multiplePwdDes: UILabel!
    @IBOutlet weak var tempPwdDes: UILabel!
    
    let vm = PasswordManagementViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "密码管理"
        self.clearsSelectionOnViewWillAppear = true
        
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SelectType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
            
        case .multiple:
            let multipleTempPwdVC: MultipleTempPasswordController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(multipleTempPwdVC, animated: true)
            
        case .temporary:
            let temporayTempPwdVC: SingleTempPasswordController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(temporayTempPwdVC, animated: true)
            
        }
    }
}
