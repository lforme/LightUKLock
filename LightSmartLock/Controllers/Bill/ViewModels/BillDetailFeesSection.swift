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
    
    private var data: Data!
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        self.supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        return data.list.count
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
        let cellData = data.list[index]
        cell.name.text = cellData.costCategoryName
        let start = cellData.cycleStartDate ?? "正在加载..."
        let end = cellData.cycleEndDate ?? "正在加载..."
        cell.date.text = "\(start) 至 \(end)"
        let money = cellData.amount ?? 0.00
        cell.price.text = "￥ \(money)"
        
        switch data.billType {
        case 1:
            cell.icon.image = UIImage(named: "yuan_icon")
        case -1:
            cell.icon.image = UIImage(named: "yuan_huang_icon")
        default:
            break
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
            
            footerView.price.text = "￥ \(data.totalMoney)"
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
        
        let totalMoney: Double
        let list: [BillInfoDetail.BillItemList]
        let billType: Int?
        init(totalMoney: Double, list: [BillInfoDetail.BillItemList], billType: Int?) {
            self.totalMoney = totalMoney
            self.list = list
            self.billType = billType
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
