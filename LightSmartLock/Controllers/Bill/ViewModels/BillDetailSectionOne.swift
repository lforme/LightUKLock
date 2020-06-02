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
    
        switch data.billStatus {
        case 0:
            cell.statusLabel.text = "待支付"
        case 999:
            cell.statusLabel.text = "已付款"
        case 1:
            cell.statusLabel.text = "部分支付"
        case -1:
            cell.statusLabel.text = "已欠租"
            cell.statusLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        default:
            break
        }
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
   
}

extension BillDetailSectionOne {
    
    final class Data: NSObject, ListDiffable {
        
        let amountPayable: Double
        let amountPaid: Double
        let assetName: String
        let billNumber: String
        let billStatus: Int
        
        init(amountPayable: Double, amountPaid: Double, assetName: String, billNumber: String, billStatus: Int) {
            self.amountPayable = amountPayable
            self.amountPaid = amountPaid
            self.assetName = assetName
            self.billNumber = billNumber
            self.billStatus = billStatus
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
