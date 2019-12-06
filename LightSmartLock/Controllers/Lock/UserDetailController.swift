//
//  UserDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class UserDetailController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        title = "用户详情"
        setupUI()
    }
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
    }
}
