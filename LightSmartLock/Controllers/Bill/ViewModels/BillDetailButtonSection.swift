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
    
    private var data: Data?
    
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
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
    
    override func didSelectItem(at index: Int) {
        let confirmVC: ConfirmArrivalController = ViewLoader.Storyboard.controller(from: "Bill")
        self.viewController?.navigationController?.pushViewController(confirmVC, animated: true)
    }
}

extension BillDetailButtonSection {
    
    final class Data: NSObject, ListDiffable {
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}

