//
//  HouseKeeperCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class HouseKeeperCell: UICollectionViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var phone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.setCircular(radius: 20)
    }

}
