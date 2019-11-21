//
//  LoginService.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift

enum LoginValidationResult {
    case empty
    case success(message: String?)
    case failed(error: AppError?)
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}

class LoginValidationService {
    
    let minimumPhoneCount = 11
    
    
    func validatePhone(_ phone: String, password: String) -> Observable<LoginValidationResult> {
        if phone.isEmpty || password.isEmpty {
            return .just(.empty)
        }
        
        if phone.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .just(.failed(error: AppError.reason("手机号只能输入数字")))
        }
        
        if phone.count != minimumPhoneCount {
            return .just(.failed(error: AppError.reason("手机号码必须是11位")))
        }
        
        if password.isEmpty {
            return .just(.failed(error: AppError.reason("请输入密码")))
        }
        
        return .just(.success(message: nil))
    }
    
    
}
