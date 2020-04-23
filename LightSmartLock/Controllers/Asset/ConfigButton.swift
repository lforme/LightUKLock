//
//  ConfigButton.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class ConfigButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 4
        setTitleColor(.white, for: .selected)
        setTitleColor(.black, for: .normal)
        tintColor = .clear
        isSelected = false
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
                borderColor = nil
                borderWidth = 0
            } else {
                backgroundColor = .white
                borderColor = .lightGray
                borderWidth = 1

            }
        }
    }
    
    

}
