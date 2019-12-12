//
//  SharePwdSingleViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

final class SharePwdSingleViewModel {
    
    var displayShareType: Observable<TempPasswordShareType> {
        return bindShareType.asObservable()
    }
    
    let bindPhone = BehaviorRelay<String?>(value: nil)
    let bindMark = BehaviorRelay<String?>(value: nil)
    let bindShareType = BehaviorRelay<TempPasswordShareType>(value: .message)
    
    var shareAction: Action<TempPasswordShareParameter, ShareBodyModel>!
    
    init() {
        self.shareAction = Action<TempPasswordShareParameter, ShareBodyModel>(workFactory: {[unowned self] (param) -> Observable<ShareBodyModel> in
            switch self.bindShareType.value {
            case .message:
                
                if self.bindPhone.value.isNilOrEmpty {
                    return .error(AppError.reason("请检比填参数完整性"))
                } else {
                    param.Phone = self.bindPhone.value
                    param.BeginTime = Date().toFormat("yyyy-MM-dd HH:mm:ss")
                    param.EndTime = Date().toFormat("yyyy-MM-dd 23:59:59")
                    param.Mark = self.bindMark.value
                    param.ShareType = self.bindShareType.value.rawValue
                    param.SecretType = 1
                    return BusinessAPI.requestMapJSON(.generateTempBy(input: param), classType: ShareBodyModel.self)
                }
            case .qq:
                return .empty()
            case .weixin:
                return .empty()
            }
        })
    }

}
