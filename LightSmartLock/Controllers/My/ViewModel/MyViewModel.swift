//
//  MyViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PKHUD

protocol MyViewModeling {
    
    var sceneList: Observable<[SceneListModel]> { get }
    var requestFinished: Observable<Bool> { get }
    var nomore: Observable<Bool> { get }
    
    func refresh()
    func loadMore()
}

final class MyViewModel: MyViewModeling {
    
    var nomore: Observable<Bool> {
        return self._nomore.asObservable()
    }
    
    var requestFinished: Observable<Bool> {
        return self._requestFinished.asObservable()
    }
    
    var sceneList: Observable<[SceneListModel]> {
        return self._list.asObservable()
    }
    
    private let _list = BehaviorRelay<[SceneListModel]>(value: [])
    private let _requestFinished = BehaviorRelay<Bool>(value: false)
    private let _nomore = BehaviorRelay<Bool>(value: false)
    private var pageIndex = 1
    private let disposeBag: DisposeBag = DisposeBag()
    
    init() {}
    
    func refresh() {
        pageIndex = 1
        BusinessAPI.requestMapJSONArray(.getCustomerSceneList(pageIndex: pageIndex, pageSize: 15, Sort: 1), classType: SceneListModel.self, useCache: true).map  { $0.compactMap { $0 } }.subscribe(onNext: {[weak self] (models) in
            self?._list.accept(models)
            self?._requestFinished.accept(true)
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?._requestFinished.accept(true)
        }).disposed(by: disposeBag)
    }
    
    func loadMore() {
        pageIndex += 1
        BusinessAPI.requestMapJSONArray(.getCustomerSceneList(pageIndex: pageIndex, pageSize: 15, Sort: 1), classType: SceneListModel.self, useCache: true).map  { $0.compactMap { $0 } }.subscribe(onNext: {[weak self] (models) in
            guard let this = self else { return }
            if models.count != 0 {
                this._list.accept(this._list.value + models)
            } else {
                this._nomore.accept(true)
            }
            this._requestFinished.accept(true)
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?._requestFinished.accept(true)
        }).disposed(by: disposeBag)
    }
}
