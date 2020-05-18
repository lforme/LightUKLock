//
//  BillDetailSectionOneCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillDetailSectionOneCell: UICollectionViewCell {

    @IBOutlet weak var receiveableLabel: UILabel!
    @IBOutlet weak var actualPayment: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var billNumber: UILabel!
    @IBOutlet weak var addressAndTenant: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cornerRadius = 7
    }

}
