//
//  AssetDetailViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Popover
import RxCocoa
import RxSwift

extension Notification.Name {
    static let gotoAssetDetail = Notification.Name("gotoAssetDetail")
    static let refreshAssetDetail = Notification.Name("refreshAssetDetail")
}

class AssetDetailViewController: AssetBaseViewController {
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("删除", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    lazy var inviteBindingBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("邀请绑定", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    lazy var popView: UIView = {
        let view = UIStackView(arrangedSubviews: [self.inviteBindingBtn])
        view.axis = .vertical
        view.distribution = .fillEqually
        view.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
        return view
    }()
    
    lazy var popover: Popover = {
        let popover = Popover()
        popover.popoverColor = UIColor.black.withAlphaComponent(0.8)
        return popover
    }()
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var editAssetButton: UIButton!
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    @IBOutlet weak var buildingAdressLabel: UILabel!
    
    @IBOutlet weak var houseStructLabel: UILabel!
    
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    @IBOutlet weak var incomeCountLabel: UILabel!
    
    @IBOutlet weak var expenseAmountLabel: UILabel!
    
    @IBOutlet weak var expenseCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var biillView: UIView!
    @IBOutlet weak var billContainer: UIView!
    
    @IBOutlet weak var bottomContainer: ButtonContainerView!
    
    @IBOutlet weak var backgroundHeightCons: NSLayoutConstraint!
    
    let currentAsset = BehaviorRelay<PositionModel?>.init(value: nil)
    let currentStatistics = BehaviorRelay<TurnoverStatisticsDTO?>.init(value: nil)
    var assetId: String!
    var roleType: Int!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        
        moreButton.rx
            .tap
            .subscribe(onNext: { [unowned self](_) in
                self.popover.show(self.popView, fromView: self.moreButton)
            })
            .disposed(by: rx.disposeBag)
        
        inviteBindingBtn.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                self?.popover.dismiss()
                self?.performSegue(withIdentifier: "InviteBinding", sender: nil)
            })
            .disposed(by: rx.disposeBag)
        
        deleteBtn.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                self?.popover.dismiss()
                
                let alertController = UIAlertController(title: "提示", message: "请先删除资产中的门锁", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                    print("test")
                }
                alertController.addAction(confirmAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx
            .notification(.gotoAssetDetail)
            .subscribe(onNext: {[unowned self] (_) in
                self.navigationController?.popToViewController(self, animated: true)
                self.bindRx()
            })
            .disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx
            .notification(.refreshAssetDetail)
            .map { _ in }
            .startWith(())
            .subscribe(onNext: {[unowned self] (_) in
                self.bindRx()
            })
            .disposed(by: rx.disposeBag)
        
        buildingNameLabel.text = nil
        buildingAdressLabel.text = nil
        houseStructLabel.text = nil
        
        balanceLabel.text = nil
        incomeAmountLabel.text = nil
        incomeCountLabel.text = nil
        expenseAmountLabel.text = nil
        expenseCountLabel.text = nil
        
        if roleType != 1 {
            moreButton.isHidden = true
            editAssetButton.isHidden = true
            biillView.isHidden = true
            backgroundHeightCons.constant = 100
        }
        
    }
    
    
    func bindRx() {
        disposeBag = DisposeBag()
        
        let getAssetHouseDetail = BusinessAPI.requestMapJSON(.getAssetHouseDetail(id: assetId), classType: PositionModel.self)
        
        getAssetHouseDetail.subscribe(onNext: { [weak self](detail) in
            self?.currentAsset.accept(detail)
            self?.buildingNameLabel.text = detail.buildingName
            self?.buildingAdressLabel.text = detail.address
            self?.houseStructLabel.text = "\(detail.houseStruct ?? "") | \(detail.area?.description ?? "")㎡"
        })
            .disposed(by: disposeBag)
        
        
        
        let statistics = BusinessAPI2.requestMapJSON(.getStatistics(assetId: assetId), classType: TurnoverStatisticsDTO.self)
        
        statistics.subscribe(onNext: { [weak self](model) in
            self?.currentStatistics.accept(model)
            self?.balanceLabel.text = model.balance?.twoPoint
            self?.incomeAmountLabel.text = model.incomeAmount?.yuanSymbol
            self?.incomeCountLabel.text = "共\(model.incomeCount?.description ?? "")笔"
            self?.expenseAmountLabel.text = model.expenseAmount?.yuanSymbol
            self?.expenseCountLabel.text = "共\(model.expenseCount?.description ?? "")笔"
            
        })
            .disposed(by: disposeBag)
        
        
        var items = BusinessAPI2.requestMapJSONArray(.getAssetContracts(assetId: assetId), classType: TenantContractAndBillsDTO.self)
            .asDriver(onErrorJustReturn: [])
        if roleType != 1 {
            items = BusinessAPI2.requestMapJSONArray(.getTenantContracts(assetId: assetId), classType: TenantContractAndBillsDTO.self)
            .asDriver(onErrorJustReturn: [])
        }
        
        items
            .do(onNext: { [weak self](datas) in
                self?.billContainer.isHidden = datas.isEmpty
                self?.tableView.isHidden = datas.isEmpty
                if self?.roleType != 1 {
                    self?.bottomContainer.isHidden = true
                } else {
                    self?.bottomContainer.isHidden = datas.isEmpty
                }
            })
            .drive(tableView.rx.items(cellIdentifier: "TenantContractCell", cellType: TenantContractCell.self)) {[weak self] (row, element, cell) in
                cell.model = element
                cell.nav = self?.navigationController
        }
        .disposed(by: disposeBag)
    }
    
    
    @IBAction func flowAction(_ sender: Any) {
        let billFlowVC: BillFlowController = ViewLoader.Storyboard.controller(from: "Bill")
        billFlowVC.vm = BillFlowViewModel(assetId: self.assetId)
        billFlowVC.statistics = currentStatistics.value
        navigationController?.pushViewController(billFlowVC, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AssetFacilityListViewController {
            vc.assetId = assetId
        } else if let vc = segue.destination as? UtilitiesRecordsViewController {
            vc.assetId = assetId
        } else if let vc = segue.destination as? AddTenantViewController {
            vc.assetId = assetId
            vc.buildingName = buildingNameLabel.text
        } else if let vc = segue.destination as? BindingOrEditAssetViewController,
            let asset = currentAsset.value {
            vc.asset = asset
        }
    }
}

