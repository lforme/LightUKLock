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
    @IBOutlet weak var lockWayIcon: UIImageView!
    @IBOutlet weak var topLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        avatar.layer.cornerRadius = avatar.bounds.width / 2
    }
    
    func bind(_ data: UnlockRecordModel, filterType: Int) {
        self.nickname.text = data.userName
        
        switch filterType {
        case 1, 2:
            self.time.text = data.openTime?.toDate()?.toFormat("hh:mm")

        case 3:
            self.time.text = data.openTime?.toDate()?.toFormat("yy/MM/dd hh:mm")
    
        default:
            break
        }
        
        switch data.openTypeCode {
        case 1:
            self.lockWayIcon.image = UIImage(named: "home_lock_way_num")
            
        case 2, 201:
            self.lockWayIcon.image = UIImage(named: "home_lock_way_finger")
            
        case 3, 4:
            self.lockWayIcon.image = UIImage(named: "home_lock_way_card")
        case 5:
            self.lockWayIcon.image = UIImage(named: "home_lock_way_temp")
        case 6:
            self.lockWayIcon.image = UIImage(named: "home_lock_way_ble")
            
        default:
            break
        }
        
        self.unlockType.text = data.openType
    }
}

