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
    var deposit: Double?
    var endDate: String?
    var isIncrease: Int?
    var isRelatedRental: Int?
    var isRemind: Int?
    var isSeparate: Int?
    var remark: String?
    var rentCollectRate: Int?
    var rentCollectType: Int?
    var rental: Double?
    var roomNum: String?
    var startDate: String?
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
    
    @IBOutlet weak var startDateBtn: DateSelectionButton!
    
    @IBOutlet weak var endDateBtn: DateSelectionButton!
    
    @IBOutlet weak var rentCollectTypeBtn: DataSelectionButton!
    
    @IBOutlet weak var rentalTF: UITextField!
    
    @IBOutlet weak var depositTF: UITextField!
    
    @IBOutlet weak var isRemindSW: UISwitch!
    
    @IBOutlet weak var advanceDayBtn: DataSelectionButton!
    
    @IBOutlet weak var remarkTF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNumBtn.title = "请选择房间"
        roomNumBtn.items = [["A", "B", "C", "D", "E"]]
        
        idCardFrontView.placeImage = #imageLiteral(resourceName: "id_front")
        idCardReverseView.placeImage = #imageLiteral(resourceName: "id_back")
        
        reloadFellowView()
    
        rentCollectTypeBtn.title = "请选择收租周期"
        rentCollectTypeBtn.items = [["年/次", "月/次", "日/次"]]
        
        advanceDayBtn.title = "请选择提前时间"
        advanceDayBtn.items = [Array(1...15).map { $0.description + "天" }]
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
        
        // 日期
        self.tenantContractInfo.startDate = startDateBtn.selectedDateStr
        self.tenantContractInfo.endDate = endDateBtn.selectedDateStr
        
        // 收租周期
        self.tenantContractInfo.rentCollectType = rentCollectTypeBtn.result?.first?.row
        
        // 租金
        self.tenantContractInfo.rental = self.rentalTF.text?.toDouble()
        // 押金
        self.tenantContractInfo.deposit = self.depositTF.text?.toDouble()
        
        // 收款账号
        
        // 收租提醒
        self.tenantContractInfo.isRemind = self.isRemindSW.isOn ? 1 : 0
        
        // 提前时间
        var str = self.advanceDayBtn.resultStr
        str?.removeLast()
        self.tenantContractInfo.advanceDay = str?.toInt()
        
        // 备注
        self.tenantContractInfo.remark = self.remarkTF.text
    }
    
}
