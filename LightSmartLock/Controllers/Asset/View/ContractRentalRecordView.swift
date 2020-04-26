//
//  ContractRentalRecordView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Reusable

class ContractRentalRecordView: UIView, NibLoadable {

    
    @IBOutlet weak var sectionTitle: UILabel!
    
    @IBOutlet weak var startDateBtn: UIButton!
    
    @IBOutlet weak var increaseTypeBtn: UIButton!
    
    @IBOutlet weak var amountTF: UITextField!
    
    var didDeleted: (() -> Void)?
    
    func config(with record: ContractRentalRecord, index: Int, didDeleted: (() -> Void)?) {
        self.didDeleted = didDeleted
        sectionTitle.text = "递增\(index + 1)"
        
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        didDeleted?()
    }
}
