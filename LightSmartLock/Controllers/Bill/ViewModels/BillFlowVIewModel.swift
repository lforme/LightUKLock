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
import PKHUD

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
    
    let assetId: String
    
    private let _showBottomButton = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    private let _collectionViewDataSource = BehaviorRelay<[ListDiffable]>(value: [])
    
    init(assetId: String) {
        self.assetId = assetId
        
        buttonSelected.map { $0 == .flow }.bind(to: _showBottomButton).disposed(by: disposeBag)
        
        Observable.combineLatest(year, buttonSelected).flatMapLatest {[unowned self] (year, type) -> Observable<[ListDiffable]> in
            
            switch type {
            case .contract:
                return BusinessAPI.requestMapJSONArray(.tenantContractInfoAssetContract(assetId: self.assetId, year: self.year.value), classType: AssetContractModel.self, useCache: true).catchError({ (error) -> Observable<[AssetContractModel?]> in
                    PKHUD.sharedHUD.rx.showError(error)
                    return .just([])
                })
                    .map { (models) -> [BillContractSection.Data] in
                    models.compactMap { BillContractSection.Data.init(id: $0?.assetId ?? "", phone: $0?.tenantPhone ?? "", name: $0?.tenantName ?? "", house: $0?.houseName ?? "", start: $0?.startDate ?? "", end: $0?.endDate ?? "") }
                               }
            case .flow:
                var i = -1
                return BusinessAPI.requestMapJSONArray(.baseTurnoverInfoList(assetId: self.assetId, year: self.year.value), classType: AssetFlowModel.self, useCache: true).map { (models) -> [BillFlowSection.Data] in
                    models.compactMap {
                        i += 1
                        return BillFlowSection.Data(balance: $0?.balance ?? 0, date: $0?.yearAndMonth ?? "", expense: $0?.expense ?? 0, income: $0?.income ?? 0, list: $0?.turnoverDTOList ?? [], isExtend: (false, i))
                        
                    }
                }
                
            case .report:
                return BusinessAPI.requestMapJSONArray(.reportAsset(assetId: self.assetId, year: self.year.value), classType: AssetReportModel.self, useCache: true).map { (models) -> [BillFlowReportSection.Data] in
                    models.compactMap { BillFlowReportSection.Data(id: $0?.costCategoryId ?? "", name: $0?.costCategoryName, count: $0?.count ?? 0, paidCount: $0?.paidCount ?? 0, totalAmount: $0?.totalAmount ?? 0) }
                }
            }
        }.bind(to: _collectionViewDataSource).disposed(by: disposeBag)
        
    }
    
}
