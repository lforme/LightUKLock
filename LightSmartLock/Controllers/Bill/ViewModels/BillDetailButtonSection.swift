//
//  BillDetailButtonSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillDetailButtonSection: ListSectionController {
    
    private var data: Data!
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillDetailButtonCell", bundle: nil, for: self, at: index) as? BillDetailButtonCell else {
            fatalError()
        }
        
        if data.billStatus == 0 {
            cell.confirmButton.isHidden = true
            cell.rushRentButton.isHidden = false
        } else if data.billStatus == 999 {
            cell.rushRentButton.isHidden = true
            cell.confirmButton.isHidden = false
        }
        
        cell.confirmButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            let confirmVC: ConfirmArrivalController = ViewLoader.Storyboard.controller(from: "Bill")
            confirmVC.totalMoney = this.data.totalMoney
            confirmVC.billId = this.data.billId
            this.viewController?.navigationController?.pushViewController(confirmVC, animated: true)
        }).disposed(by: cell.disposeBag)
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillDetailButtonSection {
    
    final class Data: NSObject, ListDiffable {
        
        let billStatus: Int
        let billId: String
        let totalMoney: Double
        
        init(status: Int, billId: String, totalMoney: Double) {
            self.billStatus = status
            self.billId = billId
            self.totalMoney = totalMoney
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}

