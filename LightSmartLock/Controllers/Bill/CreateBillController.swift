//
//  CreateBillController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD
import HandyJSON

class CreateBillController: UIViewController {
    
    var assetId: String = ""
    var contractId: String = ""
    
    @IBOutlet weak var stackViewAdd: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var defaultPickFeeButton: UIButton!
    @IBOutlet weak var defaultField: UITextField!
    @IBOutlet weak var defaultCycleButton: UIButton!
    
    @IBOutlet weak var deadLinePickButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var accountPickButton: UIButton!
    
    let obDefaultCycleDate = BehaviorRelay<(String, String)?>(value: nil)
    let obDefaultFee = BehaviorRelay<(String, String)?>(value: nil)
    let obDefaultMoney = BehaviorRelay<String?>(value: nil)
    let obDeadLineDate = BehaviorRelay<String?>(value: nil)
    let obPhone = BehaviorRelay<String?>(value: nil)
    let obReceivingUser = BehaviorRelay<String?>(value: nil)
    let obReceivingUserId = BehaviorRelay<String?>(value: nil)
    
    var bindList = [ParamListItem]()
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "发起收款账单"
        bind()
    }
    
    func bind() {
        defaultCycleButton.rx.tap.flatMapLatest {(_) -> Observable<(String, String)> in
            return DateCyclePickerController.rx.present().do(onNext: {[weak self] (arg) in
                self?.defaultCycleButton.setTitle("\(arg.0) 至 \(arg.1)", for: UIControl.State())
            })
        }.bind(to: obDefaultCycleDate).disposed(by: rx.disposeBag)
        
        defaultPickFeeButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            let selectedVC: SelectorFeesController = ViewLoader.Storyboard.controller(from: "Bill")
            this.navigationController?.pushViewController(selectedVC, animated: true)
            
            selectedVC.didSelected = {[weak self] (name, id) in
                self?.obDefaultFee.accept((name, id))
                self?.defaultPickFeeButton.setTitle(name, for: UIControl.State())
            }
        }).disposed(by: rx.disposeBag)
        
        defaultField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: obDefaultMoney)
            .disposed(by: rx.disposeBag)
        
        addButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.bindList.append(ParamListItem())
            self?.reloadListView()
        }).disposed(by: rx.disposeBag)
        
        deadLinePickButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            DatePickerController.rx.present(with: "yyyy-MM-dd", mode: .date, maxDate: nil, miniDate: nil).subscribe(onNext: {[weak self] (date) in
                self?.deadLinePickButton.setTitle(date, for: UIControl.State())
                self?.obDeadLineDate.accept(date)
                
            }).disposed(by: this.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        phoneField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: obPhone)
            .disposed(by: rx.disposeBag)
        
        accountPickButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            let accountVC: ReceivingAccountController = ViewLoader.Storyboard.controller(from: "Bill")
            this.navigationController?.pushViewController(accountVC, animated: true)
            
            accountVC.selectedHandle {[weak self] (model) in
                guard let accountId = model.id, let name = model.account else { return }
                self?.obReceivingUser.accept(name)
                self?.obReceivingUserId.accept(accountId)
                self?.accountPickButton.setTitle(name, for: UIControl.State())
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func reloadListView() {
        stackViewAdd.arrangedSubviews.forEach {
            self.stackViewAdd.removeArrangedSubview($0)
            $0.removeFromSuperview() }
        for (index, bindModel) in bindList.enumerated() {
            let v: BillFeesDeleteView = ViewLoader.Xib.view()
            stackViewAdd.addArrangedSubview(v)
            v.tag = index
            v.snp.makeConstraints { (maker) in
                maker.height.equalTo(180)
                maker.width.equalTo(v.superview!)
            }
            v.deleteButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                self?.bindList.remove(at: v.tag)
                self?.stackViewAdd.removeArrangedSubview(v)
                v.removeFromSuperview()
                self?.reloadListView()
            }).disposed(by: v.rx.disposeBag)
            
            v.feeButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let this = self else { return }
                
                let selectedVC: SelectorFeesController = ViewLoader.Storyboard.controller(from: "Bill")
                this.navigationController?.pushViewController(selectedVC, animated: true)
                
                selectedVC.didSelected = {(name, id) in
                    bindModel.obCostCategoryName.accept(name)
                    bindModel.obCostCategoryId.accept(id)
                    v.feeButton.setTitle(name, for: UIControl.State())
                }
                
            }).disposed(by: v.rx.disposeBag)
            
            v.feeField.rx.text.orEmpty.changed
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .bind(to: bindModel.obAmount)
                .disposed(by: v.rx.disposeBag)
            
            v.cycleButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                guard let this = self else { return }
                DateCyclePickerController.rx.present().subscribe(onNext: { (arg) in
                    
                    v.cycleButton.setTitle("\(arg.0) 至 \(arg.1)", for: UIControl.State())
                    bindModel.obCycleStartDate.accept(arg.0     )
                    bindModel.obCycleEndDate.accept(arg.1)
                    
                    
                }).disposed(by: this.rx.disposeBag)
                
            }).disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func saveButtonTap(_ sender: UIButton) {
        var pass = true
        let parameter = Parameter()
        parameter.assetId = self.assetId
        parameter.contractId = self.assetId
        parameter.deadlineDate = self.obDeadLineDate.value
        parameter.receivingUser = self.obReceivingUser.value
        parameter.receivingAccountId = self.obReceivingUserId.value
        parameter.receivingPhone = self.obPhone.value
        
        let defaultListItem = BillInfoDetail.BillItemList(amount: Double(obDefaultMoney.value ?? "0"), costCategoryId: obDefaultFee.value?.1, costCategoryName: obDefaultFee.value?.0, cycleStartDate: obDefaultCycleDate.value?.0, cycleEndDate: obDefaultCycleDate.value?.1)
        
        var temp = bindList.map { $0.convertTo() }
        temp.insert(defaultListItem, at: 0)
        
        temp.forEach { (item) in
            if item.amount?.description.isEmpty ?? false {
                pass = false
                HUD.flash(.label("请填写金额"), delay: 2)
            } else if item.costCategoryId.isNilOrEmpty {
                pass = false
                HUD.flash(.label("请填选择费用"), delay: 2)
            } else if item.cycleStartDate.isNilOrEmpty {
                pass = false
                HUD.flash(.label("请填选择周期"), delay: 2)
            }
        }
        parameter.billItemDTOList = temp
        if parameter.receivingAccountId.isNilOrEmpty {
            pass = false
        }
        
        if pass {
            
            BusinessAPI.requestMapBool(.addBillInfo(parameter: parameter)).subscribe(onNext: {[weak self] (success) in
                if success {
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.accountWay)
                    self?.navigationController?.popViewController(animated: true)
                }
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
}

extension CreateBillController {
    
    class ParamListItem {
        let obAmount = BehaviorRelay<String?>(value: nil)
        let obCostCategoryId = BehaviorRelay<String?>(value: nil)
        let obCostCategoryName = BehaviorRelay<String?>(value: nil)
        let obCycleEndDate = BehaviorRelay<String?>(value: nil)
        let obCycleStartDate = BehaviorRelay<String?>(value: nil)
        
        func convertTo() -> BillInfoDetail.BillItemList {
            let amount = obAmount.value ?? "0"
            
            let model = BillInfoDetail.BillItemList.init(amount: Double(amount), costCategoryId: self.obCostCategoryId.value, costCategoryName: self.obCostCategoryName.value, cycleStartDate: self.obCycleStartDate.value, cycleEndDate: self.obCycleEndDate.value)
            
            return model
        }
    }
    
    class Parameter: HandyJSON {
        
        required init() { }
        
        var assetId: String?
        var contractId: String?
        var deadlineDate: String?
        var receivingAccountId: String?
        var receivingUser: String?
        var receivingPhone: String?
        var billItemDTOList: [BillInfoDetail.BillItemList]?
    }
}
