//
//  BillFlowLeaseRenewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/28.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class BillFlowLeaseRenewController: UITableViewController {
    
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var addAndSubPicker: DataSelectionButton!
    @IBOutlet weak var adjustWayButton: DataSelectionButton!
    @IBOutlet weak var durationButton: DataSelectionButton!
    @IBOutlet weak var afterRentLabel: UILabel!
    @IBOutlet weak var afterEndLabel: UILabel!
    
    let addAndSubArray = [["加租", "减租"]]
    let adjustWayArray = [["按金额", "按比例"]]
    let durationArray = [["年", "月"], Array(1...12).map { $0.description }]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "续租"
        setupUI()
        bind()
    }
    
    func bind() {
        addAndSubPicker.items = addAndSubArray
        adjustWayButton.items = adjustWayArray
        durationButton.items = durationArray
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
