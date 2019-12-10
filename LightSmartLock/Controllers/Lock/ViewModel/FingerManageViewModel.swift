//
//  FingerManageViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD

final class FingerManageViewModel: ListViewModeling {
    
    typealias Item = FingerModel
    
    var refreshStatus: Observable<UKRefreshStatus> {
        return _refreshStatus.asObservable()
    }
    
    var list: Observable<[FingerModel]> {
        return _list.asObservable()
    }
    
    var pageIndex: Int = 1
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let _refreshStatus = BehaviorRelay<UKRefreshStatus>(value: .none)
    private let _list = BehaviorSubject<[FingerModel]>(value: [])
    
    func refresh() {
        pageIndex = 1
        guard let id = LSLUser.current().userInScene?.customerID else {
            HUD.flash(.label("无法从服务器获取用户Id, 请稍后再试"), delay: 2)
            return
        }
        BusinessAPI.requestMapJSONArray(.getFingerPrintKeyList(customerId: id, index: pageIndex, pageSize: 15), classType: FingerModel.self, useCache: true).map { $0.compactMap { $0 } } .do( onError: {[weak self] (_) in
            self?._refreshStatus.accept(.endHeaderRefresh)
            }, onCompleted: {[weak self] in
                self?._refreshStatus.accept(.endHeaderRefresh)
        }).bind(to: _list).disposed(by: disposeBag)
    }
    
    func loadMore() {
        pageIndex += 1
        guard let id = LSLUser.current().userInScene?.customerID else {
            HUD.flash(.label("无法从服务器获取用户Id, 请稍后再试"), delay: 2)
            return
        }
        BusinessAPI.requestMapJSONArray(.getFingerPrintKeyList(customerId: id, index: pageIndex, pageSize: 15), classType: FingerModel.self, useCache: true).map { $0.compactMap { $0 } }
            .subscribe(onNext: {[weak self] (models) in
                guard let this = self else { return }
                this._refreshStatus.accept(.endFooterRefresh)
                if models.count != 0 {
                    this._list.onNext(try! this._list.value() + models)
                } else {
                    this._refreshStatus.accept(.noMoreData)
                }
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?._refreshStatus.accept(.endFooterRefresh)
            }).disposed(by: disposeBag)
    }
}
