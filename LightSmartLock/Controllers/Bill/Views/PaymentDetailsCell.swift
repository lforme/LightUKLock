//
//  PaymentDetailsCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class PaymentDetailsCell: UICollectionViewCell {

    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var flowNumber: UILabel!
    @IBOutlet weak var payWay: UILabel!
    @IBOutlet weak var payMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
