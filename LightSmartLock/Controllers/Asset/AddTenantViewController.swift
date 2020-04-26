//
//  AddTenantViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class TenantContractInfo: Codable {
    var advanceDay: Int?
    var assetId: String?
    class ContractCostSettingDTOList: Codable {
        var amount: Int?
        var baseProfitAmount: Int?
        var costCategoryId: String?
        var costCollectType: Int?
        var id: String?
        var initialNumber: Int?
        var isBaseProfit: Int?
        var isBottomProfit: Int?
        var isFixed: Int?
        var isInitialCharge: Int?
        var price: Int?
        var unit: Int?
    }
    var contractCostSettingDTOList: [ContractCostSettingDTOList]?
    class ContractRentalRecordDTOList: Codable {
        var increaseType: Int?
        var ratio: Int?
        var startDate: Date?
    }
    var contractRentalRecordDTOList: [ContractRentalRecordDTOList]?
    var costCollectRatio: Int?
    var costCollectType: Int?
    var deposit: Int?
    var endDate: Date?
    var isIncrease: Int?
    var isRelatedRental: Int?
    var isRemind: Int?
    var isSeparate: Int?
    var remark: String?
    var rentCollectRate: Int?
    var rentCollectType: Int?
    var rental: Int?
    var roomNum: String?
    var startDate: Date?
    var tenantFellowDTOList: [TenantMember] = []
    var tenantInfo = TenantMember()
    var userId: String?
}

class AddTenantViewController: UIViewController {
    
    let tenantContractInfo = TenantContractInfo()
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var idCardTF: UITextField!
    
    @IBOutlet weak var idCardFrontBtn: UIButton!
    
    @IBOutlet weak var idCardReverseBtn: UIButton!
    
    @IBOutlet weak var noFellowView: UIStackView!
    
    @IBOutlet weak var fellowContainerView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadFellowView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTenantFellow",
            let vc = segue.destination as? AddTenantFellowViewController {
            vc.member = sender as? TenantMember
            
            vc.addFellow = { [weak self]member, isEdit in
                // 同住人身份证
                if !isEdit {
                    self?.tenantContractInfo.tenantFellowDTOList.append(member)
                    
                }
                self?.reloadFellowView()
            }
            
        }
    }
    
    func reloadFellowView() {
        noFellowView.isHidden = !self.tenantContractInfo.tenantFellowDTOList.isEmpty
        fellowContainerView.isHidden = self.tenantContractInfo.tenantFellowDTOList.isEmpty
        fellowContainerView.subviews.forEach { $0.removeFromSuperview()}
        for (index, fellow) in self.tenantContractInfo.tenantFellowDTOList.enumerated() {
            let fellowView = TenantFellowInfoView.loadFromNib()
            fellowView.snp.makeConstraints { (make) in
                make.height.equalTo(44)
            }
            fellowView.config(with: fellow, didDeleted: { [weak self] in
                self?.tenantContractInfo.tenantFellowDTOList.remove(at: index)
                self?.reloadFellowView()
            }) { [weak self] in
                self?.performSegue(withIdentifier: "AddTenantFellow", sender: fellow)
                
            }
            
            fellowContainerView.addArrangedSubview(fellowView)
        }
    }
    
    
    @IBAction func nextStepAction(_ sender: Any) {
        // 承租人身份证
        self.tenantContractInfo.tenantInfo.userName = userNameTF.text
        self.tenantContractInfo.tenantInfo.phone = phoneTF.text
        self.tenantContractInfo.tenantInfo.idCard = idCardTF.text
        
    }
    
}
