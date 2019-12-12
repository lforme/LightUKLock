//
//  PasswordChangeStatusCell.swift
//  Lllidan_Apartment
//
//  Created by 木瓜 on 2018/4/10.
//  Copyright © 2018年 WHY. All rights reserved.
//

import UIKit

class PasswordChangeStatusCell: UITableViewCell {
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var dot: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dot.clipsToBounds = true
        dot.layer.cornerRadius = dot.bounds.width / 2
        
    }
}
