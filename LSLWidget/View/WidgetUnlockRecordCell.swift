//
//  WidgetUnlockRecordCell.swift
//  LSLWidget
//
//  Created by mugua on 2020/1/2.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class WidgetUnlockRecordCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unlockWayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 7
    }
}
