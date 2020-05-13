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

class BillFlowContractDetailController: UITableViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合同详情"
        setupUI()
        bind()
        
    }
    
    func bind() {
        BusinessAPI.requestMapJSON(.tenantContractInfo(contractId: "4672476535362420739"), classType: AssetContractDetailModel.self).subscribe(onNext: {[weak self] (model) in
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
            
            if let idCardA = model.tenantInfo?.idCardFront {
                let str = ServerHost.shared.environment.host + idCardA
                self?.idCardFront.kf.setImage(with: URL(string: str), for: UIControl.State())
            }
            
            if let idCardB = model.tenantInfo?.idCardReverse {
                let str = ServerHost.shared.environment.host + idCardB
                self?.idCardFront.kf.setImage(with: URL(string: str), for: UIControl.State())
            }
            
            if let roommateList = model.fellowInfoList {
                roommateList.forEach { (item) in
                    if let name = item.userName, let phone =
                        item.phone {
                        let label = UILabel()
                        label.sizeToFit()
                        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                        label.textColor = ColorClassification.textPrimary.value
                        label.text = "\(name) \(phone)"
                        
                        self?.roommateContainer.addArrangedSubview(label)
                    }
                }
            }
            
            self?.tableView.reloadData()
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
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
