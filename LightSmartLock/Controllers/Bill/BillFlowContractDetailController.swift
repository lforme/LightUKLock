//
//  BillFlowContractDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillFlowContractDetailController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合同详情"
        setupUI()

    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
}
