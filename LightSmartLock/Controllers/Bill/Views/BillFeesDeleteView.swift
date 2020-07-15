//
//  BillFeesDeleteView.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillFeesDeleteView: UIView {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var feeButton: UIButton!
    @IBOutlet weak var feeField: UITextField!
    @IBOutlet weak var cycleButton: UIButton!
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         commonInit()
     }

     override func awakeFromNib() {
         super.awakeFromNib()
         commonInit()
     }
     
     private func commonInit() {
         self.bounds.size.height = 180
     }


}
