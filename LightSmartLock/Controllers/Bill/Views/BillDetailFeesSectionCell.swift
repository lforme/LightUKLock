//
//  BillDetailFeesSectionCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillDetailFeesSectionCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        if LSLUser.current().scene?.roleType == .some(.member) || LSLUser.current().scene?.roleType == .some(.admin) {
            icon.image = UIImage(named: "yuan_huang_icon")
        } else {
            icon.image = UIImage(named: "yuan_icon")
        }
    }
    
}
