//
//  BankCardBindController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class BankCardBindController: UITableViewController {
    
    var canEditing: Bool = false
    
    var originModel: CollectionAccountModel?
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var bankNumberField: UITextField!
    @IBOutlet weak var bankNameField: UITextField!
    @IBOutlet weak var subranchField: UITextField!
    @IBOutlet weak var defaultSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    let obModel = BehaviorRelay<CollectionAccountModel>(value: CollectionAccountModel())
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定银行卡"
        setupUI()
        bind()
    }
    
    func bind() {
        
        if let oldModel = self.originModel {
            obModel.accept(oldModel)
            let isDefault = oldModel.isDefault ?? false
            defaultSwitch.isOn = isDefault
        }
        
        let oldValue = self.obModel.value
        oldValue.accountType = 1
        self.obModel.accept(oldValue)
        accountField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.account = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        bankNumberField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.userName = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        bankNameField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.bankName = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        bankNameField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.bankBranchName = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        defaultSwitch.rx.value.subscribe(onNext: {[unowned self] (isOn) in
            let temp = self.obModel.value
            temp.isDefault = isOn
            self.obModel.accept(temp)
        }).disposed(by: rx.disposeBag)
        
        
        let saveAction = Action<(), Bool> {[weak self] (_) -> Observable<Bool> in
            guard let this = self else {
                return .error(AppError.reason("发生未知错误"))
            }
            
            let model = this.obModel.value
            if model.account.isNilOrEmpty {
                return .error(AppError.reason("请填写用户名"))
            } else if model.userName.isNilOrEmpty {
                return .error(AppError.reason("请填写银行卡号"))
            } else if model.bankName.isNilOrEmpty {
                return .error(AppError.reason("请填写开户银行"))
            } else {
                
                return BusinessAPI.requestMapBool(.addReceivingAccount(parameter: model))
            }
        }
        
        saveButton.rx.bind(to: saveAction, input: ())
        
        saveAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        saveAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.accountWay)
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        if canEditing {
            let deleteButton = createdRightNavigationItem(title: "删除", image: nil)
            guard let id = originModel?.id else { return }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 80
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
