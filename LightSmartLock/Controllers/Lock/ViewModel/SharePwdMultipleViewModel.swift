//
//  SharePwdMultipleViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import HandyJSON

class TempPasswordShareParameter: HandyJSON {
    
    var endTime: String?
    var password: String?
    var remark: String?
    var sendPhone: String?
    var sendType: TempPasswordShareWayType? = .message
    var startTime: String?
    var type: Int? = 1
    
    required init() {}
}

enum TempPasswordShareWayType: Int, HandyJSONEnum {
    case message = 1
    case weixin
    case qq
}

final class SharePwdMultipleViewModel {
    
    var displayShareType: Observable<TempPasswordShareWayType> {
        return bindShareType.asObservable()
    }
    
    var displayStartTime: Observable<String?> {
        return bindStartTime.asObservable()
    }
    
    var displayEndTime: Observable<String?> {
        return bindEndTime.asObservable()
    }
    
    let bindStartTime = BehaviorRelay<String?>(value: nil)
    let bindEndTime = BehaviorRelay<String?>(value: nil)
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
                
                if self.bindPhone.value.isNilOrEmpty || self.bindStartTime.value.isNilOrEmpty || self.bindEndTime.value.isNilOrEmpty {
                    return .error(AppError.reason("请检比填参数完整性"))
                } else {
                    param.sendPhone = self.bindPhone.value
                    param.startTime = self.bindStartTime.value
                    param.endTime = self.bindEndTime.value
                    param.remark = self.bindMark.value
                    param.sendType = self.bindShareType.value
                    param.type = 2
                    
                    return BusinessAPI.requestMapJSON(.addTempPassword(lockId: self.lockId, parameter: param), classType: ShareBodyModel.self)
                }
            case .qq:
                return .empty()
            case .weixin:
                return .empty()
            }
        })
    }
}

