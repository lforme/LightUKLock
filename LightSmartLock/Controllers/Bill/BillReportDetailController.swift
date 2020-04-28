//
//  BillReportDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillReportDetailCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class BillReportDetailController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "流水报告"
        setupUI()
    }
    
    func setupUI() {
        tableView.emptyDataSetSource = self
        tableView.rowHeight = 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillReportDetailCell", for: indexPath) as! BillReportDetailCell
        
        return cell
    }
    
}
