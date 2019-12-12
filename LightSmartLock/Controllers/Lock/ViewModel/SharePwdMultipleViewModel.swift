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
    
    var Mark: String?
    var Phone: String?
    var ShareType: Int! = 0
    var Address: String?
    var BeginTime: String?
    var EndTime: String?
    var SecretType: Int! = 1
    
    required init() {}
}

enum TempPasswordShareType: Int {
    case weixin = 0
    case qq
    case message
}

final class SharePwdMultipleViewModel {
    
    var displayShareType: Observable<TempPasswordShareType> {
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
    
    let bindShareType = BehaviorRelay<TempPasswordShareType>(value: .message)
    
    var shareAction: Action<TempPasswordShareParameter, ShareBodyModel>!
    
    init() {
        self.shareAction = Action<TempPasswordShareParameter, ShareBodyModel>(workFactory: {[unowned self] (param) -> Observable<ShareBodyModel> in
            switch self.bindShareType.value {
            case .message:
                
                if self.bindPhone.value.isNilOrEmpty || self.bindStartTime.value.isNilOrEmpty || self.bindEndTime.value.isNilOrEmpty {
                    return .error(AppError.reason("请检比填参数完整性"))
                } else {
                    param.Phone = self.bindPhone.value
                    param.BeginTime = self.bindStartTime.value
                    param.EndTime = self.bindEndTime.value
                    param.Mark = self.bindMark.value
                    param.ShareType = self.bindShareType.value.rawValue
                    param.SecretType = 2
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

