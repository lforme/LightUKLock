//
//  RegistrationRecoveryService.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift



final class RegisAndRecoveryValidationService {
    
    let minimumSMSCount = 6
    let minimumPhoneCount = 11
    let minimumPwdCount = 6
    
    func validateSMS(_ code: String) -> Observable<LoginValidationResult> {
        if code.isEmpty {
            return .just(.empty)
        }
        
        if code.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .just(.failed(error: AppError.reason("短信验证码只能输入数字")))
        }
        
        if code.count != minimumSMSCount {
            return .just(.failed(error: AppError.reason("短信验证码必须是6位")))
        }
        
        return .just(.success)
    }
    
    func validatePhone(_ phone: String) -> Observable<LoginValidationResult> {
        if phone.isEmpty {
            return .just(.empty)
        }
        
        if phone.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .just(.failed(error: AppError.reason("手机号只能输入数字")))
        }
        
        if phone.count != minimumPhoneCount {
            return .just(.failed(error: AppError.reason("手机号必须是11位")))
        }
        
        return .just(.success)
    }
    
    func validatePwd(_ pwd: String) -> Observable<LoginValidationResult> {
        if pwd.isEmpty {
            return .just(.empty)
        }
        
        if pwd.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .just(.failed(error: AppError.reason("短信验证码只能输入数字")))
        }
        
        if pwd.count >= minimumPwdCount {
            return .just(.failed(error: AppError.reason("密码必须大于等于6位")))
        }
        
        return .just(.success)
    }
}
