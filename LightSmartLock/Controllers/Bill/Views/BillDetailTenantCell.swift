//
//  BillDetailTenantCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillDetailTenantCell: UICollectionViewCell {

    @IBOutlet weak var tenantName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.cornerRadius = 7
    }

}
