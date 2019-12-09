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
    
    var digitalPwdDisplay: Observable<DigitalPasswordModel?> {
        return _digitalPwdDisplay.asObservable()
    }
    
    var passwordLogList: Observable<[DigitalPasswordLogModel]> {
        return _passwordLogList.asObservable()
    }
    
    let extend = BehaviorRelay<Bool>(value: false)
    
    private let _digitalPwdDisplay = BehaviorRelay<DigitalPasswordModel?>(value: nil)
    private let _passwordLogList = BehaviorRelay<[DigitalPasswordLogModel]>(value: [])
    private let disposeBag: DisposeBag = DisposeBag()
    
    init() {
        
        let shareRequset = BusinessAPI.requestMapJSON(.getCustomerKeyFirst(type: 1), classType: DigitalPasswordModel.self, useCache: true).do(onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).catchErrorJustReturn(DigitalPasswordModel()).share(replay: 1, scope: .forever)
        
        shareRequset.bind(to: _digitalPwdDisplay).disposed(by: disposeBag)
        
        shareRequset.flatMapLatest { (pwdModel) -> Observable<[DigitalPasswordLogModel]> in
            
            return BusinessAPI.requestMapJSONArray(.getKeyStatusChangeLogByKeyId(keyID: pwdModel.keyID, index: 1, pageSize: 50), classType: DigitalPasswordLogModel.self, useCache: true).map { $0.compactMap { $0 } }.do( onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).catchErrorJustReturn([])
        }.bind(to: _passwordLogList).disposed(by: disposeBag)
    }
}
