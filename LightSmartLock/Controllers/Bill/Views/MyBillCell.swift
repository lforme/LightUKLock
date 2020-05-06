//
//  MyBillCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import SnapKit

class MyBillCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // test code
        
        for _ in 0..<Int.random(in: 2...7) {
            let v: FeeItemView = ViewLoader.Xib.view()
            stackView.addArrangedSubview(v)
        }
        
        self.layoutIfNeeded()
    }

}
