//
//  NotificationsSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class NotificationsSettingController: UITableViewController, NavigationSettingStyle {
    
    @IBOutlet weak var messageSwitch: UISwitch!
    @IBOutlet weak var rentSwitch: UISwitch!
    @IBOutlet weak var daysLabel: UILabel!
    
    deinit {
        print("deinit \(self)")
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "消息设置"
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let days = Array(1...15).map { "\($0)天" }
            DataPickerController.rx.present(with: "请选择天数", items: [days])
                .map { $0.last?.value }
                .bind(to: daysLabel.rx.text)
                .disposed(by: rx.disposeBag)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8
    }
}
