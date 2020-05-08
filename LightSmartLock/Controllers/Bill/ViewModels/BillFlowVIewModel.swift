//
//  BillFlowVIewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import IGListKit
import SwiftDate

final class BillFlowViewModel {
    
    enum ButtonSelectedType {
        case report
        case flow
        case contract
    }
    
    var showBottomButton: Observable<Bool> {
        return _showBottomButton.asObservable()
    }
    
    let buttonSelected = BehaviorRelay<ButtonSelectedType>(value: .report)
    let year = BehaviorRelay<String>(value: Date().year.description)
    
    var collectionViewDataSource: Observable<[ListDiffable]> {
        return _collectionViewDataSource.asObservable()
    }
    
    private let _showBottomButton = BehaviorRelay<Bool>(value: false)
    private let assetId: String
    private let disposeBag = DisposeBag()
    private let _collectionViewDataSource = BehaviorRelay<[ListDiffable]>(value: [])
    
    
    init(assetId: String) {
        self.assetId = assetId
        
        buttonSelected.map { $0 == .flow }.bind(to: _showBottomButton).disposed(by: disposeBag)
        
        Observable.combineLatest(year, buttonSelected).flatMapLatest { (year, type) -> Observable<[ListDiffable]> in
            
        }
        
        BusinessAPI.requestMapJSON(.reportAsset(assetId: self.assetId, year: self.year.value), classType: AssetReportModel.self, useCache: true).subscribe().disposed(by: disposeBag)
    }
    
}
