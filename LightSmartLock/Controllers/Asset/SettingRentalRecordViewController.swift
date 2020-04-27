//
//  SettingRentalRecordViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class ContractRentalRecord: Codable {
    var increaseType: Int?
    var ratio: Int?
    var startDate: String?
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
            view.snp.makeConstraints { (make) in
                make.height.equalTo(194)
            }
            view.config(with: record, index: index) { [weak self] in
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