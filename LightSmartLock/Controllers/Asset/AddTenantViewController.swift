//
//  AddTenantViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import HandyJSON
import PKHUD
import UITextView_Placeholder

class TenantContractInfo: HandyJSON {
    var advanceDay: Int?
    var assetId: String?
    class ContractCostSettingDTOList: HandyJSON {
        var amount: Double?
        var baseProfitAmount: Double?
        var costCategoryId: String?
        // 收费方式（0：固定金额 1：抄表计算 2：手动填写）
        var costCollectType: Int?
        var id: String?
        var initialNumber: Double?
        // 是否保底（限于抄表费用）
        var isBaseProfit: Int?
        // 是否保底（0：否 1：是）
        var isBottomProfit: Int?
        // 是否固定金额（抄表类型的为0：固定金额：1，手动填写：2）
        var isFixed: Int?
        // 是否首期账单费用（0：否 1：是）
        var isInitialCharge: Int?
        // 单价（只限于抄表计算）
        var price: Double?
        // 单位（只限于抄表使用）1：元/度 2：元/吨 3: 元/立方
        var unit: Int?
        
        required init() {
            
        }
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
    
    required init() {
        
    }
}


class DateRangeButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 4
        setTitleColor(#colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1), for: .selected)
        setTitleColor(#colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 1), for: .normal)
        tintColor = .clear
        isSelected = false
        borderWidth = 1
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                borderColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
            } else {
                borderColor = #colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
            }
        }
    }
}

class AddTenantViewController: UIViewController {
    
    let tenantContractInfo = TenantContractInfo()
    
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    
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
    
    @IBOutlet var dateRangeBtns: [DateRangeButton]!
    
    @IBOutlet weak var dateRangeContainer: UIStackView!
    
    @IBOutlet weak var rentCollectTypeBtn: DataSelectionButton!
    
    @IBOutlet weak var rentalTF: UITextField!
    
    @IBOutlet weak var depositTF: UITextField!
    
    @IBOutlet weak var isRemindSW: UISwitch!
    
    @IBOutlet weak var advanceDayBtn: DataSelectionButton!
    
    @IBOutlet weak var remarkTF: UITextView!
    
    
    var buildingName: String!
    var assetId: String!
    
    var selectedDateRangeMonth: Int? {
        return dateRangeBtns.filter { $0.isSelected }.first?.tag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildingNameLabel.text = buildingName
        
        roomNumBtn.title = "请选择房间"
        roomNumBtn.items = [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]]
        
        idCardFrontView.placeImage = #imageLiteral(resourceName: "id_front")
        idCardReverseView.placeImage = #imageLiteral(resourceName: "id_back")
        
        idCardFrontView.isFront = true
        idCardReverseView.isFront = false
        
        idCardFrontView.updateIDCard = { [weak self] id in
            self?.idCardTF.text = id
        }
        
        idCardReverseView.updateIDCard = { [weak self] id in
            self?.idCardTF.text = id
        }
        
        reloadFellowView()
        
        dateRangeContainer.isHidden = true
        startDateBtn.didUpdated = { [weak self] startDateStr in
            if let startDateStr = startDateStr {
                self?.dateRangeContainer.isHidden = false
                self?.calculateEndDateStr(startDateStr: startDateStr)
            }
        }
        
        rentCollectTypeBtn.title = "请选择收租周期"
        let nums = Array(1...30).map { $0.description }
        let units = ["日/次", "月/次", "年/次"]
        rentCollectTypeBtn.items = [nums, units]
        
        advanceDayBtn.title = "请选择提前天数"
        advanceDayBtn.items = [Array(1...15).map { $0.description + "天" }]
        
        self.remarkTF.placeholder = "请输入备注内容"
    }
    
    func calculateEndDateStr(startDateStr: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let startDate = formatter.date(from: startDateStr), let months = self.selectedDateRangeMonth,
            let endDate = Calendar.current.date(byAdding: .month, value: months, to: startDate) {
            
            let endDateStr = formatter.string(from: endDate)
            endDateBtn.selectedDateStr = endDateStr
        }
        
    }
    
    @IBAction func tapAction(_ sender: DateRangeButton) {
        dateRangeBtns.forEach { $0.isSelected = false }
        sender.isSelected = true
        if let selectedDateStr = startDateBtn.selectedDateStr {
            calculateEndDateStr(startDateStr: selectedDateStr)
        }
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
            
            vc.rentalCollect = sender as? (String?, Double)
            vc.records = self.tenantContractInfo.contractRentalRecordDTOList
            vc.didSaved = { [weak self] newRecords in
                // 租金递增
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
    
    
    @IBAction func setRentalRecord(_ sender: Any) {
        
        var collect: String?
        if let rate = rentCollectTypeBtn.result?.first?.value,
            let collectType = rentCollectTypeBtn.result?.last?.value {
            collect = rate + collectType
        } else {
            HUD.flash(.label("请先选择收租日期"))
            return
        }
        
        if let rental = self.rentalTF.text?.toDouble(),
            rental != 0 {
            self.performSegue(withIdentifier: "SettingRentalRecord", sender: (collect, rental))
        } else {
            HUD.flash(.label("请先填写每期租金"))
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
        self.tenantContractInfo.rentCollectRate = rentCollectTypeBtn.result?.first?.value.toInt()
        self.tenantContractInfo.rentCollectType = rentCollectTypeBtn.result?.last?.row
        
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
        
        if self.tenantContractInfo.tenantInfo.userName == nil || self.tenantContractInfo.tenantInfo.userName?.isEmpty == true {
            HUD.flash(.label("请填写同住人姓名"))
            return
        }
        if self.tenantContractInfo.tenantInfo.phone == nil || self.tenantContractInfo.tenantInfo.phone?.count != 11 {
            HUD.flash(.label("请填写同住人手机号"))
            return
        }
        
        if self.tenantContractInfo.startDate == nil {
            HUD.flash(.label("请选择起租日期"))
            return
        }
        if self.tenantContractInfo.endDate == nil {
            HUD.flash(.label("请选择到租日期"))
            return
        }
        
        if self.tenantContractInfo.rentCollectRate == nil || self.tenantContractInfo.rentCollectType == nil {
            HUD.flash(.label("请选择收租日期"))
            return
        }
        
        if self.tenantContractInfo.rental == nil {
            HUD.flash(.label("请填写每期租金"))
            return
        }
    }
    
}
