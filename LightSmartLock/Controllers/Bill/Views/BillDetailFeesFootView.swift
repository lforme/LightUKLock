//
//  BillDetailFeesFootView.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillDetailFeesFootView: UICollectionViewCell {
    
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 7)
    }
    
}
