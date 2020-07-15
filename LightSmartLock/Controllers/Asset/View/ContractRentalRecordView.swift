//
//  ContractRentalRecordView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

class ContractRentalRecordView: UIView, NibLoadable {
    
    
    @IBOutlet weak var sectionTitle: UILabel!
    
    @IBOutlet weak var startDateBtn: DateSelectionButton!
    
    @IBOutlet weak var increaseTypeBtn: DataSelectionButton!
    
    @IBOutlet weak var amountTF: UITextField!
    
    @IBOutlet weak var amountTitleLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var amountContainer: UIStackView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    var didDeleted: (() -> Void)?
    
    var record: ContractRentalRecord?
    
    func config(with record: ContractRentalRecord, baseAmount: Double, index: Int, didDeleted: (() -> Void)?) {
        self.didDeleted = didDeleted
        sectionTitle.text = "递增\(record.index)"
        self.record = record
        
        increaseTypeBtn.title = "请选择"
        increaseTypeBtn.items = [["按金额", "按百分比"]]
        
        startDateBtn.didUpdated = { [weak self]selectedDateStr in
            self?.record?.startDate = selectedDateStr
        }
        startDateBtn.selectedDateStr = record.startDate
        
        
        increaseTypeBtn.didUpdated = { [weak self]result in
            self?.amountContainer.isHidden = false
            self?.amountTF.text = nil
            self?.resultLabel.text = nil
            let row = result.first?.row
            self?.record?.increaseType = row
            if row == 0 {
                self?.amountTitleLabel.text = "涨租金额"
                self?.unitLabel.text = "元"
            } else {
                self?.amountTitleLabel.text = "涨租百分比"
                self?.unitLabel.text = "%"
            }
        }
        if let increaseType = record.increaseType {
            let value = increaseType == 0 ? "按金额" : "按百分比"
            increaseTypeBtn.result = [(0, increaseType, value)]
        } else {
            amountContainer.isHidden = true
            resultLabel.text = nil
        }
        
        amountTF.rx.text
            .orEmpty
            .startWith(record.ratio?.description ?? "")
            .filterEmpty()
            .subscribe(onNext: { [weak self](amount) in
                self?.record?.ratio = amount.toDouble()
                if self?.record?.increaseType == 0 {
                    self?.resultLabel.text = String(format: "涨为%.2f元", baseAmount + (amount.toDouble() ?? 0))
                } else {
                    let percent = (amount.toDouble() ?? 0) / 100.0
                    self?.resultLabel.text = String(format: "涨为%.2f元", baseAmount * (1 + percent))
                }
            })
            .disposed(by: rx.disposeBag)
        amountTF.text = record.ratio?.description
        
    }
        
    @IBAction func deleteAction(_ sender: Any) {
        didDeleted?()
    }
}
