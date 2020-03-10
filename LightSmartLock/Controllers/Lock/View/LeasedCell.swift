//
//  LeasedCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/2/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class LeasedCell: UITableViewCell {

    @IBOutlet weak var unlocker: UILabel!
    @IBOutlet weak var unlockTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        self.selectionStyle = .none
    }

    func bind(unlocker: String?, lastUnlockTime: String?) {
        self.unlocker.text = unlocker
        if let time = lastUnlockTime {
            self.unlockTime.text = "最近开门 \(time)"
        }
    }
}
