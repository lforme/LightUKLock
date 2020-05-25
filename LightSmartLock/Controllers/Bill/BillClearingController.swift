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
import PKHUD
import Action

class BillClearingController: UIViewController {
    
    @IBOutlet weak var dynamicContainer: UIStackView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var payAmount: UILabel!
    @IBOutlet weak var nameOfTenantAsset: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var leaseBackButton: UIButton!
    
    var assetId: String! = ""
    var contractId: String! = ""
    var startTime: String! = ""
    var endTime: String! = ""
    
    var phone: String?
    var billId: String?
    var submitArray = [BillLiquidationModel.BindModel]()
    var originalModel: BillLiquidationModel?
    
    private let canEditing = BehaviorRelay<Bool>(value: false)
    
    private var callBackBillId: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "清算账单"
        setupUI()
        setupNavigationItems()
        bind()
        
    }
    
    func handleCompetition(_ block: @escaping (String) -> Void) {
        self.callBackBillId = block
    }
    
    func bind() {
        BusinessAPI.requestMapJSON(.billInfoClearing(assetId: self.assetId, contractId: self.contractId, startDate: self.startTime, endDate: self.endTime), classType: BillLiquidationModel.self).subscribe(onNext: {[weak self] (model) in
            self?.callBackBillId?(model.id ?? "")
            self?.originalModel = model
            self?.billId = model.billId
            let money = model.payableAmount ?? 0.00
            self?.payAmount.text = "￥ \(money.description)"
            let aseetName = model.assetName ?? "正在加载..."
            let tenant = model.tenantName ?? "正在加载..."
            self?.nameOfTenantAsset.text = "\(aseetName)--\(tenant)"
            self?.phone = model.phone
            self?.startDate.text = model.clearStartSate ?? "正在加载..."
            self?.endDate.text = model.clearEndSate ?? "正在加载"
            
            if let list = model.billClearingItemDTOList {
                self?.submitArray = list.map { BillLiquidationModel.BindModel(costCategoryId: $0.costCategoryId ?? "", costInfo: $0.costInfo ?? "", costName: $0.costName ?? "正在加载", amount: $0.amount ?? 0.00) }
                
                self?.submitArray.forEach { (bindModel) in
                    
                    let itemView: BillDescriptionCell = ViewLoader.Xib.view()
                    itemView.nameLabel.text = bindModel.costName
                    itemView.valueLabel.text = String(bindModel.amount.value ?? "")
                    itemView.textField.rx.text.orEmpty.changed
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .distinctUntilChanged().bind(to: bindModel.amount)
                        .disposed(by: itemView.rx.disposeBag)
                    self?.dynamicContainer.addArrangedSubview(itemView)
                }
            }
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        let shareEditing = canEditing.share()
        
        shareEditing.subscribe(onNext: {[weak self] (editing) in
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
        self.leaseBackButton.addTarget(self, action: #selector(leaseBackButtonTap(_:)), for: .touchUpInside)
    }
    
    func setupNavigationItems() {
        let rightItemButton = createdRightNavigationItem(title: "编辑", font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium), image: nil, rightEdge: 8, color: ColorClassification.navigationItem.value)
        
        rightItemButton.addTarget(self, action: #selector(rightNavigationTap(_:)), for: .touchUpInside)
        
    }
    
    @objc func leaseBackButtonTap(_ btn: UIButton) {
        if var param = originalModel {
            let items = submitArray.map { $0.convertTo() }
            param.billClearingItemDTOList = items
            BusinessAPI.requestMapBool(.editBillInfoClear(parameter: param)).subscribe(onNext: {[weak self] (success) in
                if success {
                    self?.navigationController?.popViewController(animated: true)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        } else {
            HUD.flash(.label("清算失败"), delay: 2)
        }
    }
    
    @objc func rightNavigationTap(_ btn: UIButton) {
        
        self.showActionSheet(title: nil, message: nil, buttonTitles: ["编辑", "删除", "取消"], highlightedButtonIndex: 2).subscribe(onNext: {[weak self] (index) in
            guard let this = self else { return }
            if index == 0 {
                btn.isSelected = !btn.isSelected
                this.canEditing.accept(!btn.isSelected)
            } else {
                guard let id = this.billId else {
                    HUD.flash(.label("没有账单Id,无法删除"), delay: 2)
                    return
                }
                BusinessAPI.requestMapBool(.deleteBillInfo(billId: id)).subscribe(onNext: {[weak self] (success) in
                    if success {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }).disposed(by: this.rx.disposeBag)
            }
        }).disposed(by: rx.disposeBag)
    }
}
