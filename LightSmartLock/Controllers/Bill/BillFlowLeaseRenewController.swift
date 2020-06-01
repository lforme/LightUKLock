//
//  BillFlowLeaseRenewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/28.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import SwiftDate
import PKHUD

class BillFlowLeaseRenewController: UITableViewController {
    
    @IBOutlet weak var currentRentLabel: UILabel!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var addAndSubPicker: DataSelectionButton!
    @IBOutlet weak var adjustWayButton: DataSelectionButton!
    @IBOutlet weak var durationButton: DataSelectionButton!
    
    @IBOutlet weak var afterRentLabel: UILabel!
    @IBOutlet weak var afterEndLabel: UILabel!
    @IBOutlet weak var moneyUnit: UILabel!
    @IBOutlet weak var moneyField: UITextField!
    
    let addAndSubArray = [["加租", "减租"]]
    let adjustWayArray = [["按金额", "按比例"]]
    let durationArray = [["年", "月"], Array(1...12).map { $0.description }]
    
    var contractId = ""
    var originModel: AssetContractDetailModel?
    
    let isIncrease = BehaviorRelay<Bool>(value: false)
    let isProportion = BehaviorRelay<Bool>(value: false)
    let money = BehaviorRelay<String?>(value: "0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "续租"
        setupUI()
        bind()
    }
    
    func bind() {
        addAndSubPicker.items = addAndSubArray
        adjustWayButton.items = adjustWayArray
        durationButton.items = durationArray
        
        let payMethod = originModel?.payMethod ?? "-"
        let rental = originModel?.rental ?? "-"
        let currentRental = originModel?.lastRental ?? "-"
        rentLabel.text = "\(rental) (\(payMethod))"
        currentRentLabel.text = "\(currentRental) (\(payMethod))"
        endLabel.text = originModel?.endDate
        
        addAndSubPicker.didUpdated = {[weak self] (arg) in
            guard let reslut = arg.last else { return }
            self?.isIncrease.accept(reslut.row == 0)
        }
        
        adjustWayButton.didUpdated = {[weak self] (arg) in
            guard let reslut = arg.last else { return }
            self?.isProportion.accept(reslut.row == 1)
        }
        
        isProportion.subscribe(onNext: {[weak self] (proportion) in
            if proportion {
                self?.moneyUnit.text = "%"
            } else {
                self?.moneyUnit.text = "元"
            }
        }).disposed(by: rx.disposeBag)
        
        moneyField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: money).disposed(by: rx.disposeBag)
        
        money.subscribe(onNext: {[unowned self] (text) in
            let method = self.originModel?.payMethod ?? ""
            let currentValue = Double(text ?? "0") ?? 0.0
            let oldRental = Double(self.originModel?.rental ?? "0") ?? 0.0
            
            if self.isProportion.value {
                let x = currentValue / 100
                var v = 0.0
                if self.isIncrease.value {
                    v = oldRental + oldRental * x
                } else {
                    v = oldRental - oldRental * x
                }
                self.afterRentLabel.text = "\(v) (\(method))"
            } else {
                var v = 0.0
                if self.isIncrease.value {
                    v = oldRental + currentValue
                } else {
                    v = oldRental - currentValue
                }
                self.afterRentLabel.text = "\(v) (\(method))"
            }
            
        }).disposed(by: rx.disposeBag)
        
        durationButton.didUpdated = {[unowned self] (arg) in
            let timeUnit = arg[0].row
            let value = arg[1].row + 1
            
            if timeUnit == 0 {
                
                let afterDays = (self.originModel?.endDate?.toDate())! + value.years
                self.afterEndLabel.text = afterDays.toFormat("yyyy-MM-dd")
            } else {
                let afterDays = (self.originModel?.endDate?.toDate())! + value.months
                self.afterEndLabel.text = afterDays.toFormat("yyyy-MM-dd")
            }
        }
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    @IBAction func saveButtonTap(_ sender: UIButton) {
        let end = self.afterEndLabel.text ?? ""
        let increaseType = self.isProportion.value ? 2 : 1
        let ratio = Double(self.money.value ?? "0") ?? 0
        let rentalChangeType = self.isIncrease.value ? 1 : -1
        
        if addAndSubPicker.resultStr == "请选择" {
            HUD.flash(.label("请选择加租减租"), delay: 2)
            return
        } else if adjustWayButton.resultStr == "请选择" {
            HUD.flash(.label("请选择调整方式"), delay: 2)
            return
        } else if money.value.isNilOrEmpty {
            HUD.flash(.label("请填写金额"), delay: 2)
            return
        } else if durationButton.resultStr == "请选择" {
            HUD.flash(.label("请填选择续约时长"), delay: 2)
            return
        } else {
            BusinessAPI.requestMapBool(.contractRenew(contractId: self.contractId, endDate: end, increaseType: increaseType, ratio: ratio, rentalChangeType: rentalChangeType)).subscribe(onNext: {[weak self] (success) in
                if success {
                    HUD.flash(.label("成功"), delay: 2)
                    guard let tagerVC = self?.navigationController?.children.filter({ (vc) -> Bool in
                        return vc is AssetDetailViewController
                    }).last else { return }
                    self?.navigationController?.popToViewController(tagerVC, animated: true)
                    NotificationCenter.default.post(name: .refreshAssetDetail, object: nil)
                }
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
    
}
