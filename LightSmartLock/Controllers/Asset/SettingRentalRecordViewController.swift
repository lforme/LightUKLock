//
//  SettingRentalRecordViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import HandyJSON

class ContractRentalRecord: HandyJSON {
    var increaseType: Int?
    var ratio: Double?
    var startDate: String?
    
    required init() {
        
    }
}

class SettingRentalRecordViewController: UIViewController {

    @IBOutlet weak var recordContainerView: UIStackView!
    
    var records: [ContractRentalRecord] = [] {
        didSet {
            updateUI()
        }
    }
    
    var didSaved: (([ContractRentalRecord]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateUI() {
        loadViewIfNeeded()
        recordContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, record) in records.enumerated() {
            let view = ContractRentalRecordView.loadFromNib()
            view.config(with: record, baseAmount: 1000, index: index) { [weak self] in
                self?.records.remove(at: index)
            }
            recordContainerView.addArrangedSubview(view)
        }
        
    }
    

    @IBAction func addAction(_ sender: Any) {
        let record = ContractRentalRecord()
        records.append(record)

    }
    
    @IBAction func saveAction(_ sender: Any) {
        didSaved?(self.records)
        self.navigationController?.popViewController(animated: true)
    }
    
}
