//
//  BillFlowSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

final class BillFlowSection: ListSectionController {
    
    private var data: Data?
    let reload = BehaviorRelay<Void>(value: ())
    var test = false
    override init() {
        super.init()
        self.inset = .zero
        self.supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        
        if data?.isExtend.0 ?? false {
            return data?.turnoverDTOList.count ?? 0
        } else {
            return 0
        }
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillFlowCellItemCell", bundle: nil, for: self, at: index) as? BillFlowCellItemCell else {
            fatalError()
        }
        let value = data?.turnoverDTOList[index]
        cell.name.text = value?.costName
        var dateAndName = ""
        if let date = value?.payTime {
            dateAndName += date
        }
        if let personName = value?.payerName {
            dateAndName += " "
            dateAndName += personName
        }
        cell.dateAndName.text = dateAndName
        if let price = value?.amount {
            cell.price.text = "￥ \(price)"
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
            cell.month.text = data?.yearAndMonth[4..<7]
            if let income = data?.income {
                cell.inPrice.text = "￥ \(income)"
            }
            if let outPrice = data?.expense {
                cell.outPrice.text = "￥ \(outPrice)"
            }
            if let balance = data?.balance {
                cell.balance.text = "￥ \(balance)"
            }
            
            cell.expenedButton.addTarget(self, action: #selector(expendButtonTap(_:)), for: .touchUpInside)

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
    
    @objc func expendButtonTap(_ button: UIButton) {
        button.isSelected = !button.isSelected
        self.data?.isExtend.0 = button.isSelected
        NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.billFlow)
    }
}

extension BillFlowSection {
    
    final class Data: NSObject, ListDiffable {
        
        let balance: Double
        let yearAndMonth: String
        let expense: Double
        let income: Double
        let turnoverDTOList: [AssetFlowModel.TurnoverDTO]
        var isExtend: (Bool, Int)
        
        init(balance: Double, date: String, expense: Double, income: Double, list: [AssetFlowModel.TurnoverDTO], isExtend: (Bool, Int)) {
            self.balance = balance
            self.yearAndMonth = date
            self.expense = expense
            self.income = income
            self.turnoverDTOList = list
            self.isExtend = isExtend
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}
