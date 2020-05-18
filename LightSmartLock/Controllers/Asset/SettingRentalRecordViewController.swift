//
//  SettingRentalRecordViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import HandyJSON
import PKHUD

class ContractRentalRecord: HandyJSON {
    var increaseType: Int?
    var ratio: Double?
    var startDate: String?
    
    var index = 1
    
    required init() {
        
    }
}

class SettingRentalRecordViewController: AssetBaseViewController {
    
    @IBOutlet weak var rentalLabel: UILabel!
    
    @IBOutlet weak var rentalCollectLabel: UILabel!
    
    @IBOutlet weak var recordContainerView: UIStackView!
    
    var rentalCollect: (String?, Double)!
    var records: [ContractRentalRecord] = [] {
        didSet {
            if records.isEmpty {
                records.append(ContractRentalRecord())
            }
            updateUI()
        }
    }
    
    var didSaved: (([ContractRentalRecord]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rentalLabel.text = "租金：\(rentalCollect.1.twoPoint)元"
        rentalCollectLabel.text = "收租周期：\(rentalCollect.0 ?? "")"
        
    }
    
    func updateUI() {
        loadViewIfNeeded()
        recordContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, record) in records.enumerated() {
            let view = ContractRentalRecordView.loadFromNib()
            view.config(with: record, baseAmount: 1000, index: index) { [weak self] in
                self?.records.remove(at: index)
            }
            if index == 0 {
                view.deleteBtn.isHidden = true
            }
            recordContainerView.addArrangedSubview(view)
        }
        
    }
    
    
    @IBAction func addAction(_ sender: Any) {
        let record = ContractRentalRecord()
        record.index = (records.last?.index ?? 1) + 1
        records.append(record)
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        for record in records {
            if record.startDate == nil {
                HUD.flash(.label("请选择涨租时间"))
                return
            }
            if record.increaseType == nil {
                HUD.flash(.label("请选择涨租方式"))
                return
            }
            if record.ratio == nil {
                HUD.flash(.label("请填写涨租值"))
                return
            }
        }
        
        didSaved?(self.records)
        self.navigationController?.popViewController(animated: true)
    }
    
}
