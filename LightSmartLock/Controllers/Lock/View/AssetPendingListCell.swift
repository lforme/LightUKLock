//
//  AssetPendingListCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/22.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class AssetPendingListCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addiction: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func bind(_ data: AssetPendingModel) {
        name.text = data.buildingName
        addiction.text = data.houseNum
    
        if data.isBind ?? false {
           self.icon.image = UIImage(named: "radio_button_select")
        } else {
           self.icon.image = UIImage(named: "radio_button_normal")
        }
    }
    
}
