//
//  BookKeepingViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/11.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD

final class BookKeepingViewModel {
    let assetId: String
    let contractId: String
    let obTime = BehaviorRelay<String?>(value: nil)
    var itemList = [BindModel()]
    
    init(assetId: String, contractId: String) {
        self.assetId = assetId
        self.contractId = contractId
    }
    
    func addItem(complete: ()->()) {
        itemList.append(BindModel())
        complete()
    }
    
    func deleteItemBy(index: Int, complete: ()->()) {
        itemList.remove(at: index)
        complete()
    }
}

extension BookKeepingViewModel {
    
    final class BindModel {
        let obAmount = BehaviorRelay<String?>(value: nil)
        let obCostCategoryId = BehaviorRelay<String?>(value: nil)
        let obType = BehaviorRelay<Int?>(value: nil)
        let obCostName = BehaviorRelay<String?>(value: nil)
        
        func convertToAddFlowParameter() -> AddFlowParameter {
            AddFlowParameter(amount: obAmount.value, costCategoryId: obCostCategoryId.value, turnoverType: obType.value, costName: obCostName.value)
        }
    }
    
}
 
