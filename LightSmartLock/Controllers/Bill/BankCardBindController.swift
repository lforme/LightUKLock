//
//  BankCardBindController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit


class BankCardBindController: UITableViewController {
    
    var canEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定银行卡"
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        if canEditing {
            createdRightNavigationItem(title: "删除", image: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 80
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
