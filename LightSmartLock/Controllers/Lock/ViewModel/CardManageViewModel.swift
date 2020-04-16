//
//  CardManageViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD


final class CardManageViewModel {
    
    var list: Observable<[OpenLockInfoModel.Card]> {
        return _list.asObservable()
    }
    var disposeBag: DisposeBag = DisposeBag()
    
    private let _list = BehaviorSubject<[OpenLockInfoModel.Card]>(value: [])
    
    func refresh() {
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁编号"), delay: 2)
            return
        }
        
        BusinessAPI.requestMapJSON(.getAllOpenWay(lockId: lockId), classType: OpenLockInfoModel.self).map { ($0.ladderCardVOList?.compactMap { $0 } ?? []) }.subscribe(onNext: {[weak self] (items) in
            self?._list.onNext(items)
            }, onError: { (error) in
                self._list.onError(error)
        }).disposed(by: disposeBag)
    }
    
}
