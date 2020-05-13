//
//  BillContractSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillContractSection: ListSectionController {
    
    private var data: Data?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 100)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillContractCell", bundle: nil, for: self, at: index) as? BillContractCell else {
            fatalError()
        }
        cell.name.text = data?.name
        cell.phone.text = data?.phone
        if let start = data?.start, let end = data?.end {
            cell.date.text = "短租  \(start)至\(end)"
        }
        if let house = data?.house {
            cell.house.text = "房源  \(house)"
        }
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

extension BillContractSection {
    
    final class Data: NSObject, ListDiffable {
        
        let id: String
        let phone: String
        let name: String
        let house: String
        let start: String
        let end: String
        
        init(id: String, phone: String, name: String, house: String, start: String, end: String) {
            self.id = id
            self.phone = phone
            self.name = name
            self.house = house
            self.start = start
            self.end = end
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
