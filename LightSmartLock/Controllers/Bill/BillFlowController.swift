//
//  BillFlowController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import IGListKit
import PKHUD

class BillFlowController: UIViewController {
    
    @IBOutlet weak var bookkeepingButton: UIButton!
    @IBOutlet weak var collectionViewBottomOffset: NSLayoutConstraint!
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var flowButton: UIButton!
    @IBOutlet weak var contractButton: UIButton!
    
    @IBOutlet weak var collectionView: ListCollectionView! = {
        let layout = ListCollectionViewLayout(stickyHeaders: false, scrollDirection: .vertical, topContentInset: 0, stretchToEdge: true)
        let view = ListCollectionView(frame: .zero, listCollectionViewLayout: layout)
        view.backgroundColor = ColorClassification.tableViewBackground.value
        return view
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let vm = BillFlowViewModel(assetId: "4671384247706058755")
    var dataSource = [ListDiffable]()
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账单流水"
        setupUI()
        bind()
    }
    
    func bind() {
        vm.showBottomButton.subscribe(onNext: {[unowned self] (show) in
            if show {
                self.view.bringSubviewToFront(self.bookkeepingButton)
                self.collectionViewBottomOffset.constant = 60
            } else {
                self.view.sendSubviewToBack(self.bookkeepingButton)
                self.collectionViewBottomOffset.constant = 0
            }
        }).disposed(by: rx.disposeBag)
        
        reportButton.rx.tap.map { BillFlowViewModel.ButtonSelectedType.report }.bind(to: vm.buttonSelected).disposed(by: rx.disposeBag)
        
        flowButton.rx.tap.map { BillFlowViewModel.ButtonSelectedType.flow }.bind(to: vm.buttonSelected).disposed(by: rx.disposeBag)
        
        contractButton.rx.tap.map { BillFlowViewModel.ButtonSelectedType.contract }.bind(to: vm.buttonSelected).disposed(by: rx.disposeBag)
        
        vm.buttonSelected.subscribe(onNext: {[unowned self] (selectedType) in
            switch selectedType {
            case .flow:
                self.flowButton.isSelected = true
                self.reportButton.isSelected = false
                self.contractButton.isSelected = false
            case .report:
                self.flowButton.isSelected = false
                self.reportButton.isSelected = true
                self.contractButton.isSelected = false
            case .contract:
                self.flowButton.isSelected = false
                self.reportButton.isSelected = false
                self.contractButton.isSelected = true
            }
        }).disposed(by: rx.disposeBag)
        
        vm.collectionViewDataSource.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.adapter.reloadData(completion: nil)
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .billFlow:
                self?.adapter.reloadData(completion: nil)
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        adapter.collectionView = collectionView
        collectionView.emptyDataSetSource = self
        adapter.dataSource = self
        
        [flowButton, reportButton, contractButton].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.primary.value, for: .selected)
        }
    }
}

extension BillFlowController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return dataSource
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is BillFlowReportSection.Data {
            let section = BillFlowReportSection()
            section.assetId = self.vm.assetId
            return section
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

extension BillFlowController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BookKeepingController {
            let bookKeepingVC = segue.destination as! BookKeepingController
            bookKeepingVC.assetId = "4672365253421433859"
            bookKeepingVC.contractId = "4673814997878439939"
        }
    }
}
