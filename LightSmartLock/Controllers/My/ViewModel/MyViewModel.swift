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


final class MyViewModel {
    
    var requestFinished: Observable<Bool> {
        return self._requestFinished.asObservable()
    }
    
    var sceneList: Observable<[SceneListModel]> {
        return self._list.asObservable()
    }
    
    private let _list = BehaviorRelay<[SceneListModel]>(value: [])
    private let _requestFinished = BehaviorRelay<Bool>(value: false)
    private let disposeBag: DisposeBag = DisposeBag()
    
    init() {}
    
    func refresh() {
        
        BusinessAPI.requestMapJSONArray(.getHouses, classType: SceneListModel.self, useCache: true).map  { $0.compactMap { $0 } }.subscribe(onNext: {[weak self] (models) in
            self?._list.accept(models)
            self?._requestFinished.accept(true)
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?._requestFinished.accept(true)
        }).disposed(by: disposeBag)
    }
}
