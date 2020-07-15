//
//  BindLockListCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/4.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BindLockListCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var snLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            icon.image = UIImage(named: "radio_button_select")
        } else {
            icon.image = UIImage(named: "radio_button_normal")
        }
    }
    
}
