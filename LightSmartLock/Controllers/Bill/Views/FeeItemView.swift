//
//  FeeItemView.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class FeeItemView: UIView {
    
    @IBOutlet weak var cotegoryName: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        self.layoutIfNeeded()
        if LSLUser.current().scene?.roleType == .some(.member) || LSLUser.current().scene?.roleType == .some(.admin) {
            icon.image = UIImage(named: "yuan_huang_icon")
        } else {
            icon.image = UIImage(named: "yuan_icon")
        }
    }
}
