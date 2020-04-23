//
//  PasswordManagementViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PKHUD

final class PasswordManagementViewModel {
    
    var info: Observable<OpenLockInfoModel.LadderNumberPasswordVO?> {
        return _info.asObservable()
    }
    let extend = BehaviorRelay<Bool>(value: false)
    var disposeBag: DisposeBag = DisposeBag()
    
    private let _info = BehaviorSubject<OpenLockInfoModel.LadderNumberPasswordVO?>(value: nil)
    
    func refresh() {
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁编号"), delay: 2)
            return
        }
        
        BusinessAPI.requestMapJSON(.getAllOpenWay(lockId: lockId), classType: OpenLockInfoModel.self).map { $0.ladderNumberPasswordVO }.subscribe(onNext: {[weak self] (model) in
            self?._info.onNext(model)
            }, onError: {[weak self] (error) in
                self?._info.onError(error)
        }).disposed(by: disposeBag)
        
    }
}
