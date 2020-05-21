//
//  BillFlowContractDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import Kingfisher
import Action
import RxSwift
import RxCocoa

class BillFlowContractDetailController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.primary.value
    }
    
    @IBOutlet weak var houseName: UILabel!
    @IBOutlet weak var tenantName: UILabel!
    @IBOutlet weak var tenantPhone: UILabel!
    @IBOutlet weak var tenantIdCard: UILabel!
    @IBOutlet weak var idCardFront: UIButton!
    @IBOutlet weak var idCardBack: UIButton!
    @IBOutlet weak var roommateContainer: UIStackView!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var deposit: UILabel!
    @IBOutlet weak var rental: UILabel!
    @IBOutlet weak var payMethod: UILabel!
    @IBOutlet weak var isIncrease: UILabel!
    @IBOutlet weak var isRemind: UILabel!
    @IBOutlet weak var isSeparate: UILabel!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var leaseBackButton: UIButton!
    @IBOutlet weak var leaseRenewButton: UIButton!
    
    var contractId = ""
    
    private var assetId = ""
    private var startTime = ""
    private var endTime = ""
    private var fetchModel: AssetContractDetailModel?
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合同详情"
        setupUI()
        bind()
        
    }
    
    func bind() {
        BusinessAPI.requestMapJSON(.tenantContractInfo(contractId: self.contractId), classType: AssetContractDetailModel.self).subscribe(onNext: {[weak self] (model) in
            self?.fetchModel = model
            self?.assetId = model.assetId ?? ""
            self?.startTime = model.startDate ?? ""
            self?.endTime = model.endDate ?? ""
            self?.houseName.text = model.houseName
            self?.tenantName.text = model.tenantName
            self?.tenantPhone.text = model.tenantInfo?.phone
            self?.tenantIdCard.text = model.tenantInfo?.idCard
            self?.startDate.text = model.startDate
            self?.endDate.text = model.endDate
            self?.payMethod.text = model.payMethod
            self?.rental.text = model.rental
            self?.deposit.text = model.deposit
            self?.isIncrease.text = model.isIncrease ?? false ? "递增" : "不递增"
            self?.isRemind.text = model.isRemind ?? false ? "提醒" : "不提醒"
            self?.isSeparate.text = model.isSeparate ?? false ? "分开收取" : "不分开收取"
            self?.remark.text = model.remark
            
            self?.idCardFront.setUrl(model.tenantInfo?.idCardFront)
            self?.idCardBack.setUrl(model.tenantInfo?.idCardReverse)
            
            if let roommateList = model.fellowInfoList {
                roommateList.forEach { (item) in
                    let name = item.userName ?? "正在加载"
                    let phone = item.phone ?? "正在加载"
                    let label = UILabel()
                    label.sizeToFit()
                    label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                    label.textColor = ColorClassification.textPrimary.value
                    label.text = "\(name)  \(phone)"
                    
                    self?.roommateContainer.addArrangedSubview(label)
                }
            }
            
            self?.tableView.reloadData()
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        let leaseBackAction = Action<Void, Bool> {[unowned self] (_) -> Observable<Bool> in
            return BusinessAPI.requestMapBool(.checkTerminationTenantContract(contractId: self.contractId))
        }
        
        leaseBackButton.rx.bind(to: leaseBackAction, input: ())
        
        leaseBackAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        leaseBackAction.elements.subscribe(onNext: {[weak self] (pass) in
            guard let this = self else { return }
            if pass {
                let liquidationVC: LiquidationViewController = ViewLoader.Storyboard.controller(from: "Bill")
                this.navigationController?.pushViewController(liquidationVC, animated: true)
            } else {
                this.showAlert(title: "退租失败", message: "点前有何有部分账单未清算", buttonTitles: ["取消", "去结清"], highlightedButtonIndex: 1).subscribe(onNext: { (index) in
                    if index == 1 {
                        let clearVC: BillClearingController = ViewLoader.Storyboard.controller(from: "Bill")
                        clearVC.assetId = this.assetId
                        clearVC.contractId = this.contractId
                        clearVC.startTime = this.startTime
                        clearVC.endTime = this.endTime
                        this.navigationController?.pushViewController(clearVC, animated: true)
                    }
                }).disposed(by: this.rx.disposeBag)
            }
        }).disposed(by: rx.disposeBag)
        
        leaseRenewButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            let leaseRenewVC: BillFlowLeaseRenewController = ViewLoader.Storyboard.controller(from: "Bill")
            leaseRenewVC.contractId = self.contractId
            leaseRenewVC.originModel = self.fetchModel
            self.navigationController?.pushViewController(leaseRenewVC, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        view.backgroundColor = ColorClassification.tableViewBackground.value
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
}
