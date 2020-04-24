//
//  AddUtilitiesRecordViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/24.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddUtilitiesRecordModel: Codable {
    var actualFee: String?
    var code: String?
    var company: String?
    var currentGage: String?
    var currentUse: String?
    var guaranteeFee: String?
    var isGuarantee: Bool?
    var lastGage: String?
    var price: String?
    var recordDate: String?
    var type: UtilitiesType?
}

class AddUtilitiesRecordViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var companyTypeLabel: UILabel!
    
    @IBOutlet weak var companyTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var recordDateLabel: UIButton!
    
    @IBOutlet weak var priceTF: UITextField!
    
    @IBOutlet weak var lastGageTF: UITextField!
    
    @IBOutlet weak var currentGageTF: UITextField!
    
    @IBOutlet weak var currentUseLabel: UILabel!
    
    @IBOutlet weak var actualFeeTF: UITextField!
    
    @IBOutlet weak var guaranteeFee: UISwitch!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var priceUnitLabel: UILabel!
    
    var type: UtilitiesType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeLabel.text = type.text + "费"
        companyTypeLabel.text = "供\(type.text)公司"
        priceUnitLabel.text = "元/\(type.unit)"
        
        let price = priceTF.rx.text.orEmpty.asObservable().map(Double.init)
        let lastGage = lastGageTF.rx.text.orEmpty.asObservable().map(Double.init)
        let currentGage = currentGageTF.rx.text.orEmpty.asObservable().map(Double.init)
        let currentUse = Observable.combineLatest(lastGage, currentGage) { (last, current) -> Double in
            guard let last = last, let current = current else { return 0 }
            return current - last
        }
        
        currentUse.subscribe(onNext: { [weak self](use) in
            self?.currentUseLabel.text = String(format: "%.2f", use)
        })
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(price, currentUse) { (price1, currentUse1) -> Double in
            guard let price1 = price1 else { return 0 }
            return price1 * currentUse1
        }
        .subscribe(onNext: { [weak self](fee) in
            self?.actualFeeTF.text = String(format: "%.2f", fee)
        })
            .disposed(by: rx.disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self](_) in
                
                var addModel = AddUtilitiesRecordModel()
                addModel.company = self?.companyTF.text
                addModel.code = self?.codeTF.text
                addModel.recordDate = ""
                addModel.price = self?.priceTF.text
                addModel.lastGage = self?.lastGageTF.text
                addModel.currentGage = self?.currentGageTF.text
                addModel.currentUse = self?.currentUseLabel.text
                addModel.actualFee = self?.actualFeeTF.text
                addModel.isGuarantee = self?.guaranteeFee.isOn
//                addModel.guaranteeFee = ""
                addModel.type = self?.type
                
                print(addModel)
                
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
}
