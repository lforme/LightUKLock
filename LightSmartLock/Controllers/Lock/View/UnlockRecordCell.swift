//
//  UnlockRecordCell.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate
import Kingfisher

class UnlockRecordCell: UITableViewCell {

    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var unlockType: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = ColorClassification.tableViewBackground.value
        nickname.textColor = ColorClassification.textPrimary.value
        time.textColor = ColorClassification.textDescription.value
        unlockType.textColor = ColorClassification.textDescription.value
        
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatar.bounds.width / 2
    }

    func bind(_ data: UnlockRecordModel) {
        self.nickname.text = data.userName
        self.time.text = data.openTime
        self.unlockType.text = data.openType
    }
}
