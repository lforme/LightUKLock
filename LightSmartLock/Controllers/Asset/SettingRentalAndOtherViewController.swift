//
//  SettingRentalAndOtherViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/12.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class OtherFeeCell: UITableViewCell {
    
    @IBOutlet weak var nameBtn: UIButton!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var initNumLabel: UILabel!
    
    var index: Int = 0
    
    var didDeleted: ((Int) -> Void)?
    
    func config(with model: ContractCostSettingDTOList, index: Int) {
        self.index = index
        nameBtn.setTitle(model.costCategoryName, for: .normal)
        if model.costCollectType == 1 {
            amountLabel.text = model.price?.description
            if let unit = model.unit {
                unitLabel.text = ["元/度", "元/吨", "元/立方"][unit - 1]
            }
            initNumLabel.text = model.initialNumber?.description
        } else {
            amountLabel.text = model.amount?.description
            unitLabel.text = nil
            initNumLabel.text = "-"
        }
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        self.didDeleted?(index)
    }
    
}

class SettingRentalAndOtherViewController: AssetBaseViewController {
    
    
    @IBOutlet weak var seperateSW: UISwitch!
    
    @IBOutlet weak var costCollectBtn: DataSelectionButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var tenantContractInfo: TenantContractInfo!
    
    private let otherItems = BehaviorRelay<[ContractCostSettingDTOList]>.init(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        
        costCollectBtn.title = "请选择"
        let nums = Array(1...30).map { $0.description }
        let units = ["日/次", "月/次", "年/次"]
        costCollectBtn.items = [nums, units]
        
        otherItems
            .bind(to: tableView.rx.items(cellIdentifier: "OtherFeeCell", cellType: OtherFeeCell.self)) { (row, element, cell) in
                cell.config(with: element, index: row)
                cell.didDeleted = nil
                cell.didDeleted = { [unowned self] index in
                    var value = self.otherItems.value
                    value.remove(at: index)
                    self.otherItems.accept(value)
                }
        }
        .disposed(by: rx.disposeBag)
        
        saveBtn.rx.tap
            .asObservable()
            .flatMap { [unowned self] _ -> Observable<TenantContractInfo> in
                self.tenantContractInfo.isRelatedRental = self.seperateSW.isOn ? 0 : 1
                guard let ratio = self.costCollectBtn.result?.first?.value.toInt(),
                    let type = self.costCollectBtn.result?.last.value?.row else {
                        HUD.flash(.label("请选择其他费用周期"))
                        return .empty()
                }
                
                self.tenantContractInfo.costCollectRatio = ratio
                self.tenantContractInfo.costCollectType = type + 1
                return Observable.just(self.tenantContractInfo)
                
        }
        .flatMapFirst { (info) -> Observable<Any> in
            return BusinessAPI2.requestMapAny(.addNewTenantContractInfo(info: info))
                .catchErrorJustReturn("保存失败，请重试！")
        }
        .flatMap { (response) -> Observable<String?> in
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
            return .just(message)
        }
        .subscribe(onNext: { [weak self](message) in
            if message == "保存成功" {
                HUD.flash(.label("保存成功"), onView: nil, delay: 0.5) { _ in
                    self?.performSegue(withIdentifier: "AddTenantSuccess", sender: nil)
                }
            } else {
                HUD.flash(.label(message))
            }
            
        })
            .disposed(by: rx.disposeBag)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddOtherViewController {
            vc.didSaved = { [unowned self] other in
                let value = self.otherItems.value
                self.otherItems.accept((value + [other]))
            }
        } else if let vc = segue.destination as? AddTenantSuccessViewController {
            let info = TenantSuccessInfo()
            info.houseNum = tenantContractInfo.buildingName
            info.name = tenantContractInfo.tenantInfo.userName
            info.cycleDate = (tenantContractInfo.startDate ?? "") + "至" + (tenantContractInfo.endDate ?? "")
            info.rental = (tenantContractInfo.rental?.description ?? "") + "元"
            vc.successInfo = info
        }
    }
    
}
