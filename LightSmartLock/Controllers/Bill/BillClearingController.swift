//
//  BillClearingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/29.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BillClearingController: UIViewController {
    
    @IBOutlet weak var dynamicContainer: UIStackView!
    let testCan = BehaviorRelay<Bool>(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "清算账单"
        setupUI()
        setupNavigationItems()
        testCode()
    }
    
    func testCode() {
        for _ in 0...10 {
            let v: BillDescriptionCell = ViewLoader.Xib.view()
            dynamicContainer.addArrangedSubview(v)
        }

        testCan.subscribe(onNext: {[weak self] (editing) in
            guard let this = self else{ return }
            
            if editing {
                this.dynamicContainer.arrangedSubviews.forEach { (v) in
                    let cell = v as? BillDescriptionCell
                    cell?.editingIcon.isHidden = false
                    cell?.textField.isUserInteractionEnabled = true
                }
                
            } else {
                this.dynamicContainer.arrangedSubviews.forEach { (v) in
                    let cell = v as? BillDescriptionCell
                    cell?.editingIcon.isHidden = true
                    cell?.textField.isUserInteractionEnabled = false
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.viewBackground.value
    }
    
    func setupNavigationItems() {
        let rightItemButton = createdRightNavigationItem(title: "···", font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium), image: nil, rightEdge: 8, color: ColorClassification.textPrimary.value)
        
        rightItemButton.addTarget(self, action: #selector(rightNavigationTap(_:)), for: .touchUpInside)
        
    }
    
    @objc func rightNavigationTap(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        testCan.accept(!btn.isSelected)
    }
}
