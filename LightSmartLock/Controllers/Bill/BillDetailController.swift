//
//  BillDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import IGListKit

class BillDetailController: UIViewController {
    
    var collectionView: ListCollectionView = {
        let layout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: .vertical, topContentInset: 0, stretchToEdge: false)
        let c = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
        c.backgroundColor = ColorClassification.tableViewBackground.value
        return c
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账单明细"
        setupUI()
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
        return [BillDetailSectionOne.Data(), BillDetailFeesSection.Data(), BillDetailTenantSection.Data(), BillDetailPaymentSection.Data(), BillDetailButtonSection.Data()]
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
