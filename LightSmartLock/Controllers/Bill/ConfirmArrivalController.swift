//
//  ConfirmArrivalController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD
import Action

class ConfirmArrivalController: UITableViewController {
    
    var billId = ""
    var totalMoney: Double = 0.00
    let obDate = BehaviorRelay<String>(value: Date().toFormat("yyyy-MM-dd hh:mm:ss"))
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountWayLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var selectedAccountModel: CollectionAccountModel?
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "确认到账"
        setupUI()
        bind()
    }
    
    func bind() {
        obDate.bind(to: dateLabel.rx.text).disposed(by: rx.disposeBag)
        
        let confirmAction = Action<(), Bool> {[unowned self] (_) -> Observable<Bool> in
            
            guard let model = self.selectedAccountModel else {
                return .error(AppError.reason("发生未知错误"))
            }
            
            return  BusinessAPI.requestMapBool(.billInfoConfirm(accountType: model.accountType!, amount: self.totalMoney, billId: self.billId, payTime: self.obDate.value, receivingAccountId: model.id!))
        }
        
        self.confirmButton.rx.bind(to: confirmAction, input: ())
        
        confirmAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        confirmAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.accountWay)
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 80
        }
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:
            let receivingAccountVC: ReceivingAccountController = ViewLoader.Storyboard.controller(from: "Bill")
            receivingAccountVC.selectedHandle {[weak self] (model) in
                self?.selectedAccountModel = model
                switch model.accountType {
                case .some(1):
                    let way = "银行卡"
                    let name = model.account ?? "暂无"
                    self?.accountWayLabel.text = "\(way) (\(name))"
                    
                case .some(2):
                    let way = "微信"
                    let name = model.account ?? "暂无"
                    self?.accountWayLabel.text = "\(way) (\(name))"
                    
                case .some(3):
                    let way = "支付宝"
                    let name = model.account ?? "暂无"
                    self?.accountWayLabel.text = "\(way) (\(name))"
                    
                default: break
                }
            }
            self.navigationController?.pushViewController(receivingAccountVC, animated: true)
        case 2:
            DatePickerController.rx.present(with: "yyyy-MM-dd hh:mm:ss", mode: .date, maxDate: nil, miniDate: Date()).bind(to: obDate).disposed(by: rx.disposeBag)
        default:
            break
        }
    }
}
