//
//  CreateBillController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class CreateBillController: UIViewController {
    
    @IBOutlet weak var stackViewAdd: UIStackView!
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "发起收款账单"
        setupUI()
    }
    
    func setupUI() {
        
        for _ in 0..<4 {
            let v: BillFeesDeleteView = ViewLoader.Xib.view()
            stackViewAdd.addArrangedSubview(v)
            v.snp.makeConstraints { (maker) in
                maker.height.equalTo(180)
                maker.width.equalTo(v.superview!)
            }
        }
    }
    
}
