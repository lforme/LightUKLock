//
//  TodayViewModel.swift
//  LSLWidget
//
//  Created by mugua on 2020/1/2.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxDataSources

final class TodayViewModel {
    
    typealias Section = SectionModel<String, UnlockRecordModel>
    
    var sceneName: Observable<String?> {
        let jsonStr = shareDefault?.string(forKey: ShareUserDefaultsKey.scene.rawValue)
        let model = SceneListModel.deserialize(from: jsonStr)
        return .just(model?.buildingName)
    }
    
    var currentPower: Observable<String?> {
        return _currentPower.asObservable()
    }
    
    var requestExecuting: Observable<Bool> {
        return _requestExecuting.asObservable()
    }
    
    var dataSource: Observable<[Section]> {
        return _dataSource.asObservable()
    }
    
    private let _dataSource = BehaviorRelay<[Section]>(value: [])
    private let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
    private let network = MoyaProvider<TodayExtensionInterface>()
    private let _currentPower = BehaviorRelay<String?>(value: nil)
    private let _requestExecuting = BehaviorRelay<Bool>(value: false)
    private let lockId: String
    
    init(lockId: String) {
        self.lockId = lockId
        _requestExecuting.accept(true)
    
        let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
        let jsonStr = shareDefault?.string(forKey: ShareUserDefaultsKey.lockDevice.rawValue)
        
        let entiy = LockModel.deserialize(from: jsonStr)
        let num = (entiy?.powerPercent ?? 0.0) * 100
        let powerStr = "\(num) %"
        _currentPower.accept(powerStr)
      
    }
}

