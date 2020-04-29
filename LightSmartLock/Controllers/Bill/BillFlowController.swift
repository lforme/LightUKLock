//
//  BillFlowController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import IGListKit

class BillFlowController: UIViewController {
    
    @IBOutlet weak var bookkeepingButton: UIButton!
    @IBOutlet weak var collectionViewBottomOffset: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: ListCollectionView! = {
        let layout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: .vertical, topContentInset: 0, stretchToEdge: true)
        let view = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
        view.backgroundColor = ColorClassification.tableViewBackground.value
        return view
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "账单流水"
        setupUI()
    }
    
    func setupUI() {
        adapter.collectionView = collectionView
        collectionView.emptyDataSetSource = self
        adapter.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            guard let this = self else { return }
            this.view.bringSubviewToFront(this.bookkeepingButton)
            this.collectionViewBottomOffset.constant = 60
        }
    }
}

extension BillFlowController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [BillFlowReportSection.Data(), BillFlowSection.Data(), BillContractSection.Data()]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is BillFlowReportSection.Data {
            return BillFlowReportSection()
        }
        
        if object is BillFlowSection.Data {
            return BillFlowSection()
        }
        
        if object is BillContractSection.Data {
            return BillContractSection()
        }
        
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
