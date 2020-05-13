//
//  PaymentDetailsHeaderView.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class PaymentDetailsHeaderView: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 7)
    }

}
