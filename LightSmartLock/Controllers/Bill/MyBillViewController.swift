//
//  MyBillViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import MessageUI
import MJRefresh

class MyBillViewController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var topSegmentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var paidButton: UIButton!
    @IBOutlet weak var rentOwedButton: UIButton!
    @IBOutlet weak var createBillButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var assetId: String!
    var contractId: String!
    let obBillStatus = BehaviorRelay<Int?>(value: nil)
    let obIndex = BehaviorRelay<Int>(value: 1)
    var dataSource = [MyBillModel]()
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的账单"
        setupUI()
        setupTableViewRefresh()
        bind()
        setupObserver()
        setupButtonTap()
    }
    
    func setupButtonTap() {
        createBillButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            
            let createBillVC: CreateBillController = ViewLoader.Storyboard.controller(from: "Bill")
            createBillVC.assetId = self.assetId
            createBillVC.contractId = self.contractId
            self.navigationController?.pushViewController(createBillVC, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupObserver() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .accountWay:
                self?.allButton.sendActions(for: .touchUpInside)
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupTableViewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            this.obIndex.accept(1)
        })
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            this.obIndex.accept(this.obIndex.value + 1)
        })
        
        footer.setTitle("", for: .idle)
        self.tableView.mj_footer = footer
    }
    
    func setupUI() {
        [allButton, collectionButton, paidButton, rentOwedButton].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.primary.value, for: .selected)
        }
        allButton.isSelected = true
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.register(UINib(nibName: "MyBillCell", bundle: nil), forCellReuseIdentifier: "MyBillCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
        
        if LSLUser.current().scene?.roleType == .some(.superAdmin) {
            topSegmentViewHeight.constant = 44.0
            topContainerView.alpha = 1
            
        } else {
            topSegmentViewHeight.constant = 0.0
            topContainerView.alpha = 0.0
        }
    }
    
    @IBAction func allButtonTap(_ sender: UIButton) {
        sender.isSelected = true
        [collectionButton, paidButton, rentOwedButton].forEach { $0?.isSelected = false }
        obBillStatus.accept(nil)
    }
    
    
    @IBAction func collectionTap(_ sender: UIButton) {
        sender.isSelected = true
        [allButton, paidButton, rentOwedButton].forEach { $0?.isSelected = false }
        obBillStatus.accept(0)
    }
    
    @IBAction func paidTap(_ sender: UIButton) {
        sender.isSelected = true
        [allButton, rentOwedButton, collectionButton].forEach { $0?.isSelected = false }
        obBillStatus.accept(999)
    }
    
    @IBAction func rentTap(_ sender: UIButton) {
        sender.isSelected = true
        [allButton, paidButton, collectionButton].forEach { $0?.isSelected = false }
        obBillStatus.accept(-1)
    }
}

extension MyBillViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyBillCell", for: indexPath) as! MyBillCell
        let data = dataSource[indexPath.row]
        cell.bind(data)
        cell.confirmButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            let confirmVC: ConfirmArrivalController = ViewLoader.Storyboard.controller(from: "Bill")
            confirmVC.billId = data.id ?? ""
            confirmVC.totalMoney = data.amount ?? 0.00
            self?.navigationController?.pushViewController(confirmVC, animated: true)
        }).disposed(by: cell.disposeBag)
        
        
        cell.sendButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: nil)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let deadLineDate = data.deadlineDays ?? 0
            let total = data.amount ?? 0
            let value = data.billItemDTOList?.compactMap { $0 }.map {
                "\($0.costCategoryName ?? ""), ￥\($0.amount ?? 0), 周期:\($0.cycleStartDate ?? "") 至 \($0.cycleEndDate) \n"
            }
            guard let v = value else { return }
            
            let sendStr = """
            [账单信息]
            费用明细
            - - - - - - -
            \(v.joined())
            - - - - - - -
            距最晚付款日:\(deadLineDate)天
            合计金额：￥\(total)
            """
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    messageVC.messageComposeDelegate = this
                    this.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
            print(sendStr)
        }).disposed(by: cell.disposeBag)
        
        
        cell.rushRentButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: 0)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let money = data.amount ?? 0.0
            let sendStr = "尊敬的租客，您近期有一笔账单已逾期，金额：\(money)元，请您尽快缴纳，谢谢"
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    messageVC.messageComposeDelegate = this
                    this.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
        }).disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let billDetailVC = BillDetailController()
        billDetailVC.billId = dataSource[indexPath.row].id
        self.navigationController?.pushViewController(billDetailVC, animated: true)
    }
}


extension MyBillViewController {
    
    @objc func sendBillTap() {
        
    }
    
    func bind() {
        Observable.combineLatest(obBillStatus, obIndex).flatMapLatest { (status, index) -> Observable<[MyBillModel]> in
            
            return BusinessAPI.requestMapJSONArray(.billLandlordList(assetId: self.assetId, contractId: self.contractId, billStatus: status, pageIndex: index, pageSize: 15), classType: MyBillModel.self, useCache: true, isPaginating: true).map { $0.compactMap { $0 } }
        }.subscribe(onNext: {[weak self] (list) in
            self?.tableView.mj_footer?.endRefreshing()
            self?.tableView.mj_header?.endRefreshing()
            if self?.obIndex.value == 1 {
                self?.dataSource = list
                self?.tableView.mj_footer?.resetNoMoreData()
            } else {
                self?.dataSource += list
            }
            if list.count == 0 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self?.tableView.reloadData()
            }, onError: {[weak self] (error) in
                
                PKHUD.sharedHUD.rx.showError(error)
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.endRefreshing()
        }).disposed(by: rx.disposeBag)
    }
}


