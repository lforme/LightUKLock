//
//  PositionViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import Action


final class PositionViewModel {
    
    enum ButtonType {
        case delete
        case save
    }
    
    var buttonType: Observable<ButtonType> {
        return self.obButtonType.asObservable()
    }
    
    let type: PositioEditingController.EditingType
    var defaultPositionModel: Observable<PositionModel>
    
    private let obButtonType = BehaviorRelay<ButtonType>(value: .save)
    private let obVillageName = BehaviorRelay<String?>(value: nil)
    let obArea = BehaviorRelay<String?>(value: nil)
    private let obHouseType = BehaviorRelay<String?>(value: nil)
    private let obTowards = BehaviorRelay<String?>(value: nil)
    private let obDoorplate = BehaviorRelay<String?>(value: nil)
    private let obUnit = BehaviorRelay<String?>(value: nil)
    private let obCity = BehaviorRelay<String?>(value: nil)
    private let obRegion = BehaviorRelay<String?>(value: nil)
    
    private var disposeBag = DisposeBag()
    
    init(type: PositioEditingController.EditingType) {
        self.defaultPositionModel = BusinessAPI.requestMapJSON(.getSceneAssets, classType: PositionModel.self, useCache: true)
        self.type = type
        
        if type == .addNew {
            obButtonType.accept(.save)
        } else {
            Observable.combineLatest(obVillageName.asObservable(), obArea.asObservable(), obHouseType.asObservable(), obTowards.asObservable(), obDoorplate, obUnit.asObservable(), obCity.asObservable(), obRegion.asObservable()).subscribe(onNext: {[weak self] (_) in
                
                self?.obButtonType.accept(.save)
                
            }).disposed(by: disposeBag)
            
            self.obButtonType.accept(.delete)
        }
    }
}
