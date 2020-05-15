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
import HandyJSON
import PKHUD

class AddUtilitiesRecordModel: HandyJSON {
    var actualFee: Double?
    var code: String?
    var company: String?
    var currentGage: Double?
    var currentUse: Double?
    var guaranteeFee: Double?
    var isGuarantee: Int?
    var lastGage: Double?
    var price: Double?
    var recordDate: String?
    var type: Int?
    
    required init() {
        
    }
}

class AddUtilitiesRecordViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var companyTypeLabel: UILabel!
    
    @IBOutlet weak var companyTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var recordDateButton: DateSelectionButton!
    
    @IBOutlet weak var priceTF: UITextField!
    
    @IBOutlet weak var lastGageTF: UITextField!
    
    @IBOutlet weak var currentGageTF: UITextField!
    
    @IBOutlet weak var currentUseTF: UITextField!
    
    @IBOutlet weak var actualFeeTF: UITextField!
    
    @IBOutlet weak var guaranteeFee: UISwitch!
    
    @IBOutlet weak var guarenteeFeeTF: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var priceUnitLabel: UILabel!
    
    @IBOutlet weak var useUnitLabel: UILabel!
    
    
    var type: UtilitiesType!
    var assetId: String!
    var saveSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeLabel.text = type.text + "费"
        companyTypeLabel.text = "供\(type.text)公司"
        priceUnitLabel.text = "元/\(type.unit)"
        useUnitLabel.text = type.unit
        guarenteeFeeTF.isHidden = true
        
        let price = priceTF.rx.text.orEmpty.asObservable().map(Double.init)
        let lastGage = lastGageTF.rx.text.orEmpty.asObservable().map(Double.init)
        let currentGage = currentGageTF.rx.text.orEmpty.asObservable().map(Double.init)
        let currentUse = Observable.combineLatest(lastGage, currentGage) { (last, current) -> Double in
            guard let last = last, let current = current else { return 0 }
            return current - last
        }
        
        currentUse.subscribe(onNext: { [weak self](use) in
            self?.currentUseTF.text = String(format: "%.2f", use)
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
            .flatMap { [weak self] _ -> Observable<AddUtilitiesRecordModel> in
                let addModel = AddUtilitiesRecordModel()
                addModel.company = self?.companyTF.text
                addModel.code = self?.codeTF.text
                addModel.recordDate = self?.recordDateButton.selectedDateStr
                addModel.price = self?.priceTF.text?.toDouble()
                addModel.lastGage = self?.lastGageTF.text?.toDouble()
                addModel.currentGage = self?.currentGageTF.text?.toDouble()
                addModel.currentUse = self?.currentUseTF.text?.toDouble()
                addModel.actualFee = self?.actualFeeTF.text?.toDouble()
                addModel.isGuarantee = self?.guaranteeFee.isOn == true ? 1 : 0
                if addModel.isGuarantee == 1 {
                    addModel.guaranteeFee = self?.guarenteeFeeTF.text?.toDouble()
                }
                addModel.type = self?.type.rawValue
                guard addModel.recordDate != nil else {
                    HUD.flash(.label("请选择抄表日期"))
                    return .empty()
                }
                guard addModel.price != nil else {
                    HUD.flash(.label("请填写单价"))
                    return .empty()
                }
                guard addModel.lastGage != nil else {
                    HUD.flash(.label("请填写上期读数"))
                    return .empty()
                }
                guard addModel.currentGage != nil else {
                    HUD.flash(.label("请填写本期读数"))
                    return .empty()
                }
                return .just(addModel)
        }
        .flatMapLatest { [unowned self] model in
            return BusinessAPI2.requestMapAny(.addUtilitiesRecord(assetId: self.assetId, model: model))
                    .catchErrorJustReturn("保存失败，请重试！")
        }
        .subscribe(onNext: { (response) in
            var message: String?
            if let response = response as? [String: Any] {
                if let status = response["status"] as? Int, status == 200 {
                    message = "保存成功"
                } else {
                    message = response["message"] as? String
                }
                
            } else {
                message = response as? String
            }
            HUD.flash(.label(message))
            if message == "保存成功" {
                self.navigationController?.popViewController(animated: true)
                self.saveSuccess?()
            }
        })
            .disposed(by: rx.disposeBag)
    }
    
    
    
    @IBAction func changeGuarateeFee(_ sender: UISwitch) {
        self.guarenteeFeeTF.isHidden = !sender.isOn
    }
    
    
}
