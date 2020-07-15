//
//  BillDescriptionCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/29.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

final class BillDescriptionCell: UIView {
    
    @IBOutlet weak var editingIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.frame.size.width = self.superview?.frame.size.width ?? UIScreen.main.bounds.width
        self.frame.size.height = 54
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
