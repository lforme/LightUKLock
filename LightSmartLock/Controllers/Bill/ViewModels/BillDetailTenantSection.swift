//
//  BillDetailTenantSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class BillDetailTenantSection: ListSectionController {
    
    private var data: Data!
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 72)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillDetailTenantCell", bundle: nil, for: self, at: index) as? BillDetailTenantCell else {
            fatalError()
        }
        cell.tenantName.text = data.tenantName
        cell.dateLabel.text = "租期:\(data.contractStartDate)至\(data.contractEndDate)"
        
        let phoneNumber = data.phone
        cell.callButton.rx.tap.subscribe(onNext: {[] (_) in
            if phoneNumber.isEmpty {
                return
            }
            if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
        }).disposed(by: cell.rx.disposeBag)
        
        cell.callButton.isHidden = true
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
    
}

extension BillDetailTenantSection {
    
    final class Data: NSObject, ListDiffable {
        
        let tenantName: String
        let gender: String
        let age: Int
        let contractStartDate: String
        let contractEndDate: String
        let phone: String
        
        init(tenantName: String, gender: String, age: Int, start: String, end: String, phone: String) {
            self.tenantName = tenantName
            self.gender = gender
            self.age = age
            self.contractStartDate = start
            self.contractEndDate = end
            self.phone = phone
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
