//
//  BillDetailSectionOne.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillDetailSectionOne: ListSectionController {
    
    private var data: Data!
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 128)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillDetailSectionOneCell", bundle: nil, for: self, at: index) as? BillDetailSectionOneCell else {
            fatalError()
        }
        
        cell.receiveableLabel.text = data.amountPayable.description
        cell.actualPayment.text = data.amountPaid.description
        let remaining = data.amountPayable - data.amountPaid
        cell.remainingLabel.text = remaining.description
        cell.addressAndTenant.text = data.assetName
        cell.billNumber.text = "账单编号: \(data.billNumber)"
    
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
    
    override func didSelectItem(at index: Int) {
        let contractDetailVC: BillFlowContractDetailController = ViewLoader.Storyboard.controller(from: "Bill")
        self.viewController?.navigationController?.pushViewController(contractDetailVC, animated: true)
    }
}

extension BillDetailSectionOne {
    
    final class Data: NSObject, ListDiffable {
        
        let amountPayable: Double
        let amountPaid: Double
        let assetName: String
        let billNumber: String
        
        init(amountPayable: Double, amountPaid: Double, assetName: String, billNumber: String) {
            self.amountPayable = amountPayable
            self.amountPaid = amountPaid
            self.assetName = assetName
            self.billNumber = billNumber
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
