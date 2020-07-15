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
    var lockInfo: Observable<LockModel>? { get }
    var homeInfo: Observable<HomeModel>? { get }
}

final class HomeViewModel: HomeViewModeling {
    
    var isInstallLock: Observable<Bool>
    var lockInfo: Observable<LockModel>?
    var homeInfo: Observable<HomeModel>?
    
    let disposeBag = DisposeBag()
    
    init() {
        
        if let lockId = LSLUser.current().scene?.ladderLockId, !lockId.isEmpty {
            isInstallLock = .just(true)
            self.lockInfo = BusinessAPI.requestMapJSON(.getLockInfo(id: lockId), classType: LockModel.self)
            self.homeInfo = BusinessAPI.requestMapJSON(.getHomeInfo(id: lockId), classType: HomeModel.self)
        } else {
            isInstallLock = .just(false)
        }
    }
    
}
