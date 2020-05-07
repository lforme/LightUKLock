//
//  BillFlowLeaseRenewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/28.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillFlowLeaseRenewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "续租"
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
