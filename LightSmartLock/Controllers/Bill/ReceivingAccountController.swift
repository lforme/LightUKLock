//
//  ReceivingAccountController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import PKHUD

class ReceivingAccountController: UIViewController {
    
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var datasource = [CollectionAccountModel]()
    
    private var didSelectedBlock: ((CollectionAccountModel) -> Void)?
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "收款账号"
        setupUI()
        fetchData()
        bind()
        setupObserver()
    }
    
    func setupObserver() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .accountWay:
                self?.fetchData()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80.0
        tableView.register(UINib.init(nibName: "ReceivingAccountCell", bundle: nil), forCellReuseIdentifier: "ReceivingAccountCell")
    }
    
    func bind() {
        
        addAccountButton.rx.tap.flatMapLatest {[unowned self] (_) -> Observable<BillInfoDetail.Payway?> in
            
            self.showActionSheet(title: "选择添加方式", message: nil, buttonTitles: ["银行卡", "微信", "支付宝", "其他"], highlightedButtonIndex: nil).map { BillInfoDetail.Payway(rawValue: $0 + 1) }
        }.subscribe(onNext: {[unowned self] (type) in
            guard let ways = type else { return }
            
            switch ways {
            case .alipay:
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = false
                paywayBindVC.payWay = .ali
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
                
            case .weixin:
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = false
                paywayBindVC.payWay = .wechat
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
                
            case .bank:
                let paywayBindVC: BankCardBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = false
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
                
            default:
                break
            }
            
        }).disposed(by: rx.disposeBag)
    }
}

extension ReceivingAccountController {
    
    func fetchData() {
        BusinessAPI.requestMapJSONArray(.receivingAccountList, classType: CollectionAccountModel.self, useCache: true).map { $0.compactMap { $0 } }.subscribe(onNext: {[weak self] (list) in
            self?.datasource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func selectedHandle(_ block: ((CollectionAccountModel) -> Void)?) {
        self.didSelectedBlock = block
    }
}

extension ReceivingAccountController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivingAccountCell", for: indexPath) as! ReceivingAccountCell
        let data = datasource[indexPath.row]
        cell.accountName.text = data.account
        if data.isDefault ?? false {
            cell.defaultLabel.isHidden = false
        } else {
            cell.defaultLabel.isHidden = true
        }
        switch data.accountType {
        case .some(1):
            cell.accountTypeLabel.text = "银行卡账号"
            cell.icon.setImage(UIImage(named: "bankcard_icon"), for: UIControl.State())
            cell.editButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                let paywayBindVC: BankCardBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = true
                paywayBindVC.originModel = data
                self?.navigationController?.pushViewController(paywayBindVC, animated: true)
            }).disposed(by: cell.disposeBag)
            
        case .some(2):
            cell.accountTypeLabel.text = "微信账号"
            cell.icon.setImage(UIImage(named: "wechat_icon"), for: UIControl.State())
            cell.editButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = true
                paywayBindVC.payWay = .wechat
                paywayBindVC.originModel = data
                self?.navigationController?.pushViewController(paywayBindVC, animated: true)
            }).disposed(by: cell.disposeBag)
            
        case .some(3):
            cell.accountTypeLabel.text = "支付宝账号"
            cell.icon.setImage(UIImage(named: "alipay_icon"), for: UIControl.State())
            cell.editButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = true
                paywayBindVC.payWay = .ali
                paywayBindVC.originModel = data
                self?.navigationController?.pushViewController(paywayBindVC, animated: true)
            }).disposed(by: cell.disposeBag)
            
        case .some(4):
            cell.accountTypeLabel.text = "其他账号"
            cell.icon.setImage(nil, for: UIControl.State())
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = datasource[indexPath.row]
        self.didSelectedBlock?(data)
        self.navigationController?.popViewController(animated: true)
    }
}
