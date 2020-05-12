//
//  SettingRentalAndOtherViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/12.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class SettingRentalAndOtherViewController: UIViewController {
    
    
    @IBOutlet weak var seperateSW: UISwitch!
    
    @IBOutlet weak var costCollectBtn: DataSelectionButton!
    
    var tenantContractInfo: TenantContractInfo!

    override func viewDidLoad() {
        super.viewDidLoad()

          costCollectBtn.title = "请选择其他费用周期"
          let nums = Array(1...30).map { $0.description }
          let units = ["日/次", "月/次", "年/次"]
          costCollectBtn.items = [nums, units]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
