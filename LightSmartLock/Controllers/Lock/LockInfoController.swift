//
//  LockInfoController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class LockInfoController: UITableViewController {

    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var NBLabel: UILabel!
    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var bluetooth: UILabel!
    @IBOutlet weak var finger: UILabel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "门锁信息"
        setupUI()
        bind()
    }

    func bind() {
        modeLabel.text = LSLUser.current().lockInfo?.lockType
        NBLabel.text = LSLUser.current().lockInfo?.nbVersion
        firmwareLabel.text = LSLUser.current().lockInfo?.firmwareVersion
        bluetooth.text = LSLUser.current().lockInfo?.bluetoothName
        finger.text = LSLUser.current().lockInfo?.fingerVersion
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
}
