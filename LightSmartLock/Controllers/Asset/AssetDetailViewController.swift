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
}

class AssetDetailViewController: UIViewController {
    
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
        let view = UIStackView(arrangedSubviews: [self.inviteBindingBtn, self.deleteBtn])
        view.axis = .vertical
        view.distribution = .fillEqually
        view.frame = CGRect(x: 0, y: 0, width: 80, height: 64)
        return view
    }()
    
    lazy var popover: Popover = {
        let popover = Popover()
        popover.popoverColor = UIColor.black.withAlphaComponent(0.8)
        return popover
    }()
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    @IBOutlet weak var buildingAdressLabel: UILabel!
    
    @IBOutlet weak var houseStructLabel: UILabel!
    
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    @IBOutlet weak var incomeCountLabel: UILabel!
    
    @IBOutlet weak var expenseAmountLabel: UILabel!
    
    @IBOutlet weak var expenseCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let currentAsset = BehaviorRelay<PositionModel?>.init(value: nil)
    
    var assetId: String!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            self?.balanceLabel.text = model.balance?.twoPoint
            self?.incomeAmountLabel.text = model.incomeAmount?.yuanSymbol
            self?.incomeCountLabel.text = "共\(model.incomeCount?.description ?? "")笔"
            self?.expenseAmountLabel.text = model.expenseAmount?.yuanSymbol
            self?.expenseCountLabel.text = "共\(model.expenseCount?.description ?? "")笔"
            
        })
            .disposed(by: disposeBag)
        
        
        let items = BusinessAPI2.requestMapJSONArray(.getAssetContracts(assetId: assetId), classType: TenantContractAndBillsDTO.self)
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "TenantContractCell", cellType: TenantContractCell.self)) { (row, element, cell) in
                cell.model = element
        }
        .disposed(by: disposeBag)
        
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

