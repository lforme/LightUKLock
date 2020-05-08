//
//  BillDetailFeesSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillDetailFeesSection: ListSectionController {
    
    private var data: Data?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        self.supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        return 3
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 76)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillDetailFeesSectionCell", bundle: nil, for: self, at: index) as? BillDetailFeesSectionCell else {
            fatalError()
        }
        if index == 0 {
            cell.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 7)
        }
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillDetailFeesSection: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionFooter:
            
            guard let footerView = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, nibName: "BillDetailFeesFootView", bundle: nil, at: index) as? BillDetailFeesFootView else {
                fatalError()
            }
            return footerView
            
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionFooter:
            let size = CGSize(width: collectionContext!.containerSize.width - 16, height: 56)
            return size
        default:
            fatalError()
        }
    }
}

extension BillDetailFeesSection {
    
    final class Data: NSObject, ListDiffable {
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
