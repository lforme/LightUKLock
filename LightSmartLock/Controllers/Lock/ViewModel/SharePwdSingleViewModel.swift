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
    
    var displayShareType: Observable<TempPasswordShareWayType> {
        return bindShareType.asObservable()
    }
    
    let bindPhone = BehaviorRelay<String?>(value: nil)
    let bindMark = BehaviorRelay<String?>(value: nil)
    let bindShareType = BehaviorRelay<TempPasswordShareWayType>(value: .message)
    
    var shareAction: Action<TempPasswordShareParameter, ShareBodyModel>!
    let lockId: String
    
    init(lockId: String) {
        self.lockId = lockId
        
        self.shareAction = Action<TempPasswordShareParameter, ShareBodyModel>(workFactory: {[unowned self] (param) -> Observable<ShareBodyModel> in
            switch self.bindShareType.value {
            case .message:
                
                if self.bindPhone.value.isNilOrEmpty {
                    return .error(AppError.reason("请检比填参数完整性"))
                } else {
                    param.sendPhone = self.bindPhone.value
                    param.startTime = Date().toFormat("yyyy-MM-dd HH:mm:ss")
                    param.endTime = Date().toFormat("yyyy-MM-dd 23:59:59")
                    param.remark = self.bindMark.value
                    param.sendType = self.bindShareType.value
                    param.type = 1
                    return BusinessAPI.requestMapJSON(.addTempPassword(lockId: self.lockId, parameter: param), classType: ShareBodyModel.self)
                }
                
            case .qq:
                
                param.startTime = Date().toFormat("yyyy-MM-dd HH:mm:ss")
                param.endTime = Date().toFormat("yyyy-MM-dd 23:59:59")
                param.remark = self.bindMark.value
                param.sendType = self.bindShareType.value
                param.type = 1
                return BusinessAPI.requestMapJSON(.addTempPassword(lockId: self.lockId, parameter: param), classType: ShareBodyModel.self)
                
            case .weixin:
                
                param.startTime = Date().toFormat("yyyy-MM-dd HH:mm:ss")
                param.endTime = Date().toFormat("yyyy-MM-dd 23:59:59")
                param.remark = self.bindMark.value
                param.sendType = self.bindShareType.value
                param.type = 1
                return BusinessAPI.requestMapJSON(.addTempPassword(lockId: self.lockId, parameter: param), classType: ShareBodyModel.self)
                
            }
        })
    }
}
