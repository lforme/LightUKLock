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
        
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        let reportDetailVC: BillReportDetailController = ViewLoader.Storyboard.controller(from: "Bill")
        self.viewController?.navigationController?.pushViewController(reportDetailVC, animated: true)
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillFlowReportSection {
    
    final class Data: NSObject, ListDiffable {
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
