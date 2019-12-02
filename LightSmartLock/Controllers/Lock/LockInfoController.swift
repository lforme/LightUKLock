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
        NBLabel.text = LSLUser.current().lockInfo?.NBVersion
        firmwareLabel.text = LSLUser.current().lockInfo?.lockVersion
        bluetooth.text = LSLUser.current().lockInfo?.bluthName
        finger.text = LSLUser.current().lockInfo?.fingerprintVersion
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
