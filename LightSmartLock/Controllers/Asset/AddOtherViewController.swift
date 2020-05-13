//
//  AddOtherViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/12.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import HandyJSON
import PKHUD

class ContractCostSettingDTOList: HandyJSON {
    var amount: Double?
    var baseProfitAmount: Double?
    var costCategoryId: String?
    var costCategoryName: String?
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

class AddOtherViewController: UIViewController {
    
    let other = ContractCostSettingDTOList()
    
    @IBOutlet weak var costCollectTypeBtn: DataSelectionButton!
    
    
    @IBOutlet weak var selectFeeBtn: UIButton!
    
    @IBOutlet weak var priceNameLabel: UILabel!
    
    @IBOutlet weak var priceTF: UITextField!
    
    
    @IBOutlet weak var unitBtn: DataSelectionButton!
    
    
    @IBOutlet weak var initialNumberTF: UITextField!
    
    @IBOutlet weak var unitContainer: UIStackView!
    
    @IBOutlet weak var bottomContainer: UIStackView!
    
    @IBOutlet weak var isBaseProfitSW: UISwitch!
    
    @IBOutlet weak var baseProfitAmountTF: UITextField!
    @IBOutlet weak var baseProfitAmountContainer: UIStackView!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var amountContainer: UIStackView!
    var didSaved: ((ContractCostSettingDTOList) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        costCollectTypeBtn.title = "请选择"
        costCollectTypeBtn.items = [["固定金额", "抄表计算", "手动填写"]]
        costCollectTypeBtn.didUpdated = { [weak self] results in
            self?.amountContainer.isHidden = false
            if let row = results.first?.row {
                if row == 0 {
                    self?.priceNameLabel.text = "金额"
                    self?.priceTF.placeholder = "填写每期收取的金额"
                    self?.unitContainer.isHidden = true
                    self?.bottomContainer.isHidden = true
                    self?.tipLabel.isHidden = true
                } else if row == 1 {
                    self?.priceNameLabel.text = "单价"
                    self?.priceTF.placeholder = "填写单价"
                    self?.unitContainer.isHidden = false
                    self?.bottomContainer.isHidden = false
                    self?.tipLabel.isHidden = false
                    self?.tipLabel.text = "费用=（本期读数－上期读数）×单价。小于保底单价时，账单以保底单价为准。"
                    
                } else {
                    self?.priceNameLabel.text = "金额"
                    self?.priceTF.placeholder = "填写每期收取的金额"
                    self?.unitContainer.isHidden = true
                    self?.bottomContainer.isHidden = true
                    self?.tipLabel.isHidden = false
                    self?.tipLabel.text = "手动填写的单价会体现在第一期账单中。"
                }
            }
        }
        
        amountContainer.isHidden = true
        unitContainer.isHidden = true
        bottomContainer.isHidden = true
        baseProfitAmountContainer.isHidden = true
        tipLabel.isHidden = true
        
        unitBtn.title = "请选择"
        unitBtn.items = [["元/度", "元/吨", "元/立方"]]
    }
    
    
    @IBAction func selectFeeAction(_ sender: UIButton) {
        
        let selectedVC: SelectorFeesController = ViewLoader.Storyboard.controller(from: "Bill")
        navigationController?.pushViewController(selectedVC, animated: true)
        
        selectedVC.didSelected = {[weak self] (name, id) in
            sender.setTitle(name, for: .normal)
            self?.other.costCategoryId = id
            self?.other.costCategoryName = name
        }
    }
    @IBAction func baseSwitchAction(_ sender: UISwitch) {
        baseProfitAmountContainer.isHidden = !sender.isOn
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        // 费用类型
        //        other.costCategoryId =
        guard let costCollectType = self.costCollectTypeBtn.result?.first?.row else {
            return HUD.flash(.label("请选择收费方式"))
        }
        other.costCollectType = costCollectType
        if other.costCollectType == 0 { // 固定金额
            guard let amount = self.priceTF.text?.toDouble() else {
                return HUD.flash(.label("请填写金额")) }
            other.amount = amount
        } else if other.costCollectType == 2 { // 手动填写
            guard let amount = self.priceTF.text?.toDouble() else {
                return HUD.flash(.label("请填写金额")) }
            other.amount = amount
        } else { // 抄表计算
            guard let amount = self.priceTF.text?.toDouble() else {
                return HUD.flash(.label("请填写单价")) }
            other.price = amount
            guard let row = self.unitBtn.result?.first?.row else {
                return HUD.flash(.label("请选择单位")) }
            other.unit = row + 1
            
            other.initialNumber = self.initialNumberTF.text?.toDouble()
            
            other.isBaseProfit = self.isBaseProfitSW.isOn ? 1 : 0
            
            if other.isBaseProfit == 1 {
                guard let amount = self.baseProfitAmountTF.text?.toDouble() else {
                    return HUD.flash(.label("请填写单价")) }
                other.baseProfitAmount = amount
            }
            
        }
        self.didSaved?(other)
        self.navigationController?.popViewController(animated: true)
    }
}
