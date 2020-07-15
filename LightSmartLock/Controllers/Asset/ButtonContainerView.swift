//
//  ButtonContainerView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class ButtonContainerView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: 0.04, green: 0.12, blue: 0.27, alpha: 0.09).cgColor
        layer.shadowOffset = CGSize(width: 0, height: -1.5)
        layer.shadowOpacity = 1
        layer.shadowRadius = 2.5
    }
}
