//
//  UserManagementViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PKHUD

final class UserManagementViewModel: ListViewModeling {
    
    typealias Item = UserMemberListModel
    
    var refreshStatus: Observable<UKRefreshStatus> {
        return obRefreshStatus.asObservable()
    }
    
    var list: Observable<[UserMemberListModel]> {
        return obList.asObservable()
    }
    
    var pageIndex: Int = 1
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func refresh() {
        
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁Id"), delay: 2)
            return
        }
        
        pageIndex = 1
        BusinessAPI.requestMapJSONArray(.getUserList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: Item.self, useCache: true, isPaginating: true).map { $0.compactMap { $0 } }
            .do( onError: {[weak self] (_) in
                self?.obRefreshStatus.accept(.endHeaderRefresh)
                }, onCompleted: {[weak self] in
                    self?.obRefreshStatus.accept(.endHeaderRefresh)
            })
            .bind(to: obList).disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁Id"), delay: 2)
            return
        }
        
        pageIndex += 1
        BusinessAPI.requestMapJSONArray(.getUserList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: Item.self, useCache: true, isPaginating: true).map { $0.compactMap { $0 } }
            .subscribe(onNext: {[weak self] (models) in
                guard let this = self else { return }
                
                this.obRefreshStatus.accept(.endFooterRefresh)
                
                if models.count != 0 {
                    this.obList.onNext(try! this.obList.value() + models)
                } else {
                    this.obRefreshStatus.accept(.noMoreData)
                }
                
            }, onError: {[weak self] (error) in
                self?.obRefreshStatus.accept(.endFooterRefresh)
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: disposeBag)
    }
    
    private let obRefreshStatus = BehaviorRelay<UKRefreshStatus>(value: .none)
    private let obList = BehaviorSubject<[Item]>(value: [])
    
}
