//
//  HomeViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action


protocol HomeViewModeling {
    var isInstallLock: Observable<Bool> { get }
}

final class HomeViewModel: HomeViewModeling {
    
    var isInstallLock: Observable<Bool>
    
    let disposeBag = DisposeBag()
    
    init() {
        
        let shareRequset = BusinessAPI.requestMapJSONArray(.getCustomerSceneList(pageIndex: 1, pageSize: 3, Sort: 1), classType: SceneListModel.self).share(replay: 1, scope: .forever)
        
        let networkHasLock = shareRequset.flatMapLatest { (sceneList) -> Observable<Bool> in
            let noOptionSceneList = sceneList.compactMap { $0 }
            if noOptionSceneList.count == 0 {
                return .just(false)
            }
            
            let count = noOptionSceneList.filter { $0.IsInstallLock }.count
            if count == 0 {
                return .just(false)
            } else {
                LSLUser.current().scene = noOptionSceneList.filter { $0.IsInstallLock }.first
                return .just(true)
            }
        }
        isInstallLock = Observable.combineLatest(networkHasLock, Observable.just(LSLUser.current().isInstalledLock)).map{ $0.0 && $0.1 }
    }
    
    
}
