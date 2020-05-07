//
//  AssetDetailViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Popover

class AssetDetailViewController: UIViewController {
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("删除", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    lazy var popView: UIView = {
        let view = UIStackView(arrangedSubviews: [self.deleteBtn])
        view.frame = CGRect(x: 0, y: 0, width: 64, height: 34)
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
    
    var assetId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getAssetHouseDetail = BusinessAPI.requestMapJSON(.getAssetHouseDetail(id: assetId), classType: PositionModel.self)
        
        getAssetHouseDetail.subscribe(onNext: { [weak self](detail) in
            
            self?.buildingNameLabel.text = detail.buildingName
            self?.buildingAdressLabel.text = detail.address
            self?.houseStructLabel.text = "\(detail.houseStruct ?? "") | \(detail.area?.description ?? "")㎡"
        })
            .disposed(by: rx.disposeBag)
        
        
        
        let statistics = BusinessAPI2.requestMapJSON(.getStatistics(assetId: assetId), classType: TurnoverStatisticsDTO.self)
        
        statistics.subscribe(onNext: { [weak self](model) in
            self?.balanceLabel.text = model.balance?.twoPoint
            self?.incomeAmountLabel.text = model.incomeAmount?.yuanSymbol
            self?.incomeCountLabel.text = "共\(model.incomeCount?.description ?? "")笔"
            self?.expenseAmountLabel.text = model.expenseAmount?.yuanSymbol
            self?.expenseCountLabel.text = "共\(model.expenseCount?.description ?? "")笔"

        })
            .disposed(by: rx.disposeBag)
        

        let items =         BusinessAPI2.requestMapJSONArray(.getAssetContract(assetId: assetId, year: "2020"), classType: TenantContractDTO.self)
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "TenantContractCell", cellType: TenantContractCell.self)) { (row, element, cell) in
                cell.model = element
        }
        .disposed(by: rx.disposeBag)
        
        
        
        moreButton.rx
            .tap
            .subscribe(onNext: { [unowned self](_) in
                self.popover.show(self.popView, fromView: self.moreButton)
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
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssetFacilityList",
            let vc = segue.destination as? AssetFacilityListViewController {
            vc.assetId = assetId
        }
    }
}
