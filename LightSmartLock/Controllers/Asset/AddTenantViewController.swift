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
    var contractRentalRecordDTOList: [ContractRentalRecord] = []
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
    
    
    @IBOutlet weak var roomNumBtn: DataSelectionButton!
    
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var idCardTF: UITextField!
    
    @IBOutlet weak var idCardFrontView: IDCardView!
    
    @IBOutlet weak var idCardReverseView: IDCardView!
    
    @IBOutlet weak var noFellowView: UIStackView!
    
    @IBOutlet weak var fellowContainerView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNumBtn.title = "请选择房间"
        roomNumBtn.items = [["A", "B", "C", "D", "E"]]
        
        idCardFrontView.placeImage = #imageLiteral(resourceName: "id_front")
        idCardReverseView.placeImage = #imageLiteral(resourceName: "id_back")
        
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
        
        if segue.identifier == "SettingRentalRecord",
            let vc = segue.destination as? SettingRentalRecordViewController {
            
            vc.records = self.tenantContractInfo.contractRentalRecordDTOList
            vc.didSaved = { [weak self] newRecords in
                self?.tenantContractInfo.contractRentalRecordDTOList = newRecords
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
        // 房间编号
        self.tenantContractInfo.roomNum = roomNumBtn.resultStr
        // 承租人身份证
        self.tenantContractInfo.tenantInfo.userName = userNameTF.text
        self.tenantContractInfo.tenantInfo.phone = phoneTF.text
        self.tenantContractInfo.tenantInfo.idCard = idCardTF.text
        self.tenantContractInfo.tenantInfo.idCardFront = idCardFrontView.urlStr
        self.tenantContractInfo.tenantInfo.idCardReverse = idCardReverseView.urlStr
        
        
        
    }
    
}
