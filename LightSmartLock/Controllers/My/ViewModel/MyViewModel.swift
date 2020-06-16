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
    
    let configuredList = BehaviorRelay<[BindLockListModel]>(value: [])
    
    private let _list = BehaviorSubject<[SceneListModel]>(value: [])
    private let _requestFinished = BehaviorRelay<Bool>(value: false)
    private var disposeBag: DisposeBag = DisposeBag()
    
    init() {
     
        checkConfigLockList()
    }
    
    func checkConfigLockList() {
        if let phone = LSLUser.current().user?.phone {
            BusinessAPI.requestMapJSONArray(.hardwareBindList(channels: "01", pageSize: 100, pageIndex: 1, phoneNo: phone), classType: BindLockListModel.self, useCache: false, isPaginating: true)
                .map { $0.compactMap { $0 } }.catchErrorJustReturn([])
                .bind(to: configuredList)
                .disposed(by: disposeBag)
        }
    }
    
    func refresh() {
        self.disposeBag = DisposeBag()
        
        let share = BusinessAPI.requestMapJSONArray(.getHouses, classType: SceneListModel.self, useCache: true)
            .share(replay: 1, scope: .forever)
            .do(onCompleted: {[weak self] in
                self?._requestFinished.accept(true)
            })
        
        share.map { $0.compactMap { $0 } }
            .bind(to: _list)
            .disposed(by: self.disposeBag)
    }
    
    func cellBackgroundColor(_ row: Int) -> UIColor {
        switch row {
        case 0:
            return #colorLiteral(red: 0.2509803922, green: 0.5450980392, blue: 0.9215686275, alpha: 1)
        case 1:
            return #colorLiteral(red: 0.3215686275, green: 0.5843137255, blue: 0.9254901961, alpha: 1)
        case 2:
            return #colorLiteral(red: 0.3960784314, green: 0.631372549, blue: 0.9333333333, alpha: 1)
        case 3:
            return #colorLiteral(red: 0.4666666667, green: 0.6705882353, blue: 0.937254902, alpha: 1)
        case 4:
            return #colorLiteral(red: 0.5411764706, green: 0.7176470588, blue: 0.9450980392, alpha: 1)
        default:
            return #colorLiteral(red: 0.2509803922, green: 0.5450980392, blue: 0.9215686275, alpha: 1)
        }
    }
    
    func cellRowHeight(_ row: Int) -> CGFloat {
        switch row {
        case 0:
            return 320
        default:
            return CGFloat(320 / row)
        }
    }
}
