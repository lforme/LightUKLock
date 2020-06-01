//
//  BillFlowReportSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillFlowReportSection: ListSectionController {
    
    private var data: Data?
    var assetId: String?
    var year: String!
    
    override init() {
        super.init()
        inset = .zero
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 72)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillReportCell", bundle: nil, for: self, at: index) as? BillReportCell else {
            fatalError()
        }
        if let d = data {
            cell.bind(d)
        }
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        let reportDetailVC: BillReportDetailController = ViewLoader.Storyboard.controller(from: "Bill")
        reportDetailVC.costName = data?.costCategoryName
        reportDetailVC.assetId = assetId
        reportDetailVC.costCategoryId = data?.costCategoryId
        reportDetailVC.year = year
        self.viewController?.navigationController?.pushViewController(reportDetailVC, animated: true)
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillFlowReportSection {
    
    final class Data: NSObject, ListDiffable {
        
        let costCategoryId: String
        let costCategoryName: String?
        let count: Int
        let paidCount: Int
        let totalAmount: Int
        
        init(id: String, name: String?, count: Int, paidCount: Int, totalAmount: Int) {
            self.costCategoryId = id
            self.costCategoryName = name
            self.count = count
            self.paidCount = paidCount
            self.totalAmount = totalAmount
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
