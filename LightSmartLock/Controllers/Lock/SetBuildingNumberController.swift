//
//  SetBuildingNumberController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import Action

class SetBuildingNumberController: UITableViewController {
    
    typealias EnterBuildingInfo = (_ buliding: String?, _ unit: String?, _ door: String?) -> Void
    
    @IBOutlet weak var buildingTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var doorplateTextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var doorplateButton: UIButton!
    
    private var saveButton: UIButton!
    
    private let haveToUnit = BehaviorRelay<Bool>(value: false)
    private let haveToPlate = BehaviorRelay<Bool>(value: false)
    
    private var input: EnterBuildingInfo?
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "填写楼栋单元门牌号"
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func fetchCallback(_ call: EnterBuildingInfo?) {
        self.input = call
    }
    
    func setupUI() {
        [unitButton, doorplateButton].forEach { (btn) in
            btn?.setImage(UIImage(named: "home_lock_radio_select"), for: .selected)
        }
        
        buildingTextField.keyboardType = .numberPad
        unitTextField.keyboardType = .numberPad
        doorplateTextField.keyboardType = .numberPad
        
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        self.saveButton = createdRightNavigationItem(title: "完成", image: nil)
    }
    
    func bind() {
        unitButton.rx.tap.map {[unowned self] (_) -> Bool in
            self.unitButton.isSelected = !self.unitButton.isSelected
            return self.unitButton.isSelected
        }.bind(to: haveToUnit).disposed(by: rx.disposeBag)
        
        doorplateButton.rx.tap.map {[unowned self] (_) -> Bool in
            self.doorplateButton.isSelected = !self.doorplateButton.isSelected
            return self.doorplateButton.isSelected
        }.bind(to: haveToPlate).disposed(by: rx.disposeBag)
        
        saveButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            
            guard let buildingStr = self?.buildingTextField.text, !buildingStr.isEmpty else {
                HUD.flash(.label("请填写楼栋号"), delay: 2)
                return
            }
            
            if self?.haveToUnit.value ?? false {
                guard let unitStr = self?.unitTextField.text, !unitStr.isEmpty else {
                    HUD.flash(.label("请填写单元号"), delay: 2)
                    return
                }
            }
            
            if self?.haveToPlate.value ?? false {
                guard let plateStr = self?.doorplateTextField.text, !plateStr.isEmpty else {
                    HUD.flash(.label("请填写门牌号"), delay: 2)
                    return
                }
            }
            
            self?.input?(self?.buildingTextField.text, self?.unitTextField.text, self?.doorplateTextField.text)
            self?.navigationController?.popViewController(animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
