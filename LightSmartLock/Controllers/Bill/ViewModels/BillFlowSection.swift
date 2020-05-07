//
//  BillFlowSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit


final class BillFlowSection: ListSectionController {
    
    private var data: Data?
    
    override init() {
        super.init()
        self.inset = .zero
        self.supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        return 3
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillFlowCellItemCell", bundle: nil, for: self, at: index) as? BillFlowCellItemCell else {
            fatalError()
        }
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillFlowSection: ListSupplementaryViewSource {
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            
            guard let cell = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, nibName: "BillFlowCell", bundle: nil, at: index) as? BillFlowCell else {
                fatalError()
            }
            
            return cell
            
        case UICollectionView.elementKindSectionFooter:
            
            return UICollectionReusableView.init(frame: .zero)
            
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            
            let size = CGSize(width: collectionContext!.containerSize.width, height: 80)
            return size
            
        case UICollectionView.elementKindSectionFooter:
            return CGSize.zero
        default:
            fatalError()
        }
    }
}

extension BillFlowSection {
    
    final class Data: NSObject, ListDiffable {
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
