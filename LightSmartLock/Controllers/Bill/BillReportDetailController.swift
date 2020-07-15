//
//  BillReportDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD

class BillReportDetailCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class BillReportDetailController: UITableViewController {
    
    var assetId: String?
    var costCategoryId: String?
    var costName: String?
    var year: String!
    var dataSource = [ReportFeesModel]()
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "流水报告"
        setupUI()
        bind()
    }
    
    func bind() {
        self.title = costName
        guard let assetId = self.assetId, let costId = self.costCategoryId else {
            HUD.flash(.label("无法获取资产信息"), delay: 2)
            return
        }
        BusinessAPI.requestMapJSONArray(.reportReportItems(assetId: assetId, costId: costId, year: year), classType: ReportFeesModel.self, useCache: true).subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list.compactMap({ $0 })
            self?.tableView.reloadSections(.init(integer: 0), with: .automatic)
            self?.tableView.reloadEmptyDataSet()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.emptyDataSetSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillReportDetailCell", for: indexPath) as! BillReportDetailCell
        let value = dataSource[indexPath.row]
        cell.name.text = value.costCategoryName
        if let start = value.cycleStartDate, let end = value.cycleEndDate {
            cell.date.text = "租期  \(start) 至 \(end)"
        }
        if value.billType != -1 {
            if let price = value.amount {
                cell.price.text = "￥ -\(price)"
            }
        } else {
            if let price = value.amount {
                cell.price.text = "￥ -\(price)"
            }
        }
        return cell
    }
    
}
