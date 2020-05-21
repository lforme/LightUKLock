//
//  BillDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import IGListKit
import PKHUD

class BillDetailController: UIViewController {
    
    var billId: String?
    
    fileprivate var model: BillInfoDetail?
    
    var collectionView: ListCollectionView = {
        let layout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: .vertical, topContentInset: 0, stretchToEdge: false)
        let c = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
        c.backgroundColor = ColorClassification.tableViewBackground.value
        return c
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    var dataSource = [ListDiffable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账单明细"
        setupUI()
        fetchData()
    }
    
    func setupUI() {
        self.view.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.adapter.collectionView = collectionView
        self.collectionView.emptyDataSetSource = self
        self.adapter.dataSource = self
    }
    
}

extension BillDetailController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.dataSource
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is BillDetailSectionOne.Data {
            return BillDetailSectionOne()
        }
        
        if object is BillDetailFeesSection.Data {
            return BillDetailFeesSection()
        }
        
        if object is BillDetailTenantSection.Data {
            return BillDetailTenantSection()
        }
        
        if object is BillDetailPaymentSection.Data {
            return BillDetailPaymentSection()
        }
        
        if object is BillDetailButtonSection.Data {
            return BillDetailButtonSection()
        }
        
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension BillDetailController {
    
    func fetchData() {
        guard let id = self.billId else {
            HUD.flash(.label("无法获取资产Id"), delay: 2)
            return
        }
        BusinessAPI.requestMapJSON(.billInfoDetail(billId: id), classType: BillInfoDetail.self).subscribe(onNext: {[weak self] (model) in
            self?.model = model
            
            let A = BillDetailSectionOne.Data(amountPayable: model.amountPaid ?? 0.00, amountPaid: model.amountPaid ?? 0.00, assetName: model.assetName ?? "正在加载...", billNumber: model.billNumber ?? "正在加载")
            self?.dataSource.append(A)
            
            let B = BillDetailFeesSection.Data(totalMoney: model.amountPayable ?? 0.00, list: model.billItemDTOList ?? [])
            self?.dataSource.append(B)
            
            let C = BillDetailTenantSection.Data(tenantName: model.tenantName ?? "正在加载...", gender: model.gender ?? "正在加载...", age: model.age ?? 0, start: model.contractStartDate ?? "正在加载...", end: model.contractEndDate ?? "正在加载...", phone: "1589827362")
            self?.dataSource.append(C)
            
            let E = BillDetailPaymentSection.Data(list: model.billPaymentLogDTOList ?? [])
            self?.dataSource.append(E)
            
            let F = BillDetailButtonSection.Data(status: model.billStatus ?? 0, billId: self?.billId ?? "", totalMoney: model.amountPayable ?? 0.00)
            F.model = self?.model
            self?.dataSource.append(F)
            
            self?.adapter.reloadData(completion: nil)
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
}
