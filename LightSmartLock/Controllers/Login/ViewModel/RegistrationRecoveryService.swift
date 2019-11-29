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
    
    func validateSMS(_ code: String?) -> Observable<LoginValidationResult> {
        
        guard let code = code else {
            return .error(AppError.reason("短信不能为空"))
        }
        
        if code.isEmpty {
            return .error(AppError.reason("短信不能为空"))
        }
        
        if code.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .error(AppError.reason("短信验证码只能输入数字"))
        }
        
        if code.count != minimumSMSCount {
            return .error(AppError.reason("短信验证码必须是6位"))
        }
        
        return .just(.success)
    }
    
    func validatePhone(_ phone: String?) -> Observable<LoginValidationResult> {
        
        guard let phone = phone else {
            return .error(AppError.reason("手机不能为空"))
        }
        
        if phone.isEmpty {
            return .error(AppError.reason("手机不能为空"))
        }
        
        if phone.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return .error( AppError.reason("手机号只能输入数字"))
        }
        
        if phone.count != minimumPhoneCount {
            return .error(AppError.reason("手机号必须是11位"))
        }
        
        return .just(.success)
    }
    
    func validatePwd(_ pwd: String?) -> Observable<LoginValidationResult> {
        
        guard let pwd = pwd else {
            return .error(AppError.reason("密码不能为空"))
        }
        
        if pwd.isEmpty {
            return .error(AppError.reason("密码不能为空"))
        }
        
        
        if pwd.count < minimumPwdCount {
            return .error(AppError.reason("密码必须大于等于6位"))
        }
        
        return .just(.success)
    }
}
