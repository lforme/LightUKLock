//
//  BillDetailPaymentSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillDetailPaymentSection: ListSectionController {
    
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
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 136)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "PaymentDetailsCell", bundle: nil, for: self, at: index) as? PaymentDetailsCell else {
            fatalError()
        }
        if index == 3 - 1 {
            cell.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 7)
        }
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillDetailPaymentSection: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            
            guard let headerView = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, nibName: "PaymentDetailsHeaderView", bundle: nil, at: index) as? PaymentDetailsHeaderView else {
                fatalError()
            }
            return headerView
            
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            let size = CGSize(width: collectionContext!.containerSize.width - 16, height: 56)
            return size
        default:
            fatalError()
        }
    }
}

extension BillDetailPaymentSection {
    
    final class Data: NSObject, ListDiffable {
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
