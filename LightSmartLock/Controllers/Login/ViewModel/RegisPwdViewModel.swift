//
//  RegisPwdViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/22.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol RegisForgetViewModeling {
    
    associatedtype Input = (String?, String?, String?)
    
    var phone: BehaviorSubject<String?> { get }
    var code: BehaviorSubject<String?> { get }
    var paassword: BehaviorSubject<String?> { get }
    
    var getCodeAction: Action<String?, Void> { get }
    var showPasswordAction: Action<Bool, Bool> { get }
    var regisForgetAction: Action<Input, Bool> { get }
    
}

final class RegisForgetViewModel: RegisForgetViewModeling {
    
    typealias Input = (String?, String?, String?)
    
    var getCodeAction: Action<String?, Void>
    
    var showPasswordAction: Action<Bool, Bool>
    
    var regisForgetAction: Action<Input, Bool>
    
    var phone = BehaviorSubject<String?>(value: nil)
    var code = BehaviorSubject<String?>(value: nil)
    var paassword = BehaviorSubject<String?>(value: nil)
    
    init() {
        
        getCodeAction = Action<String?, Void>(workFactory: { (phone) -> Observable<Void> in
            
            let validate = RegisAndRecoveryValidationService()
            
            return validate.validatePhone(phone).flatMapLatest { (validation) -> Observable<Void> in
                
                if validation.isValid {
                    return  AuthAPI.requestMapAny(.token).flatMapLatest { (json) -> Observable<Void> in
                        let dict = json as? [String: Any]
                        guard let token = AccessTokenModel.deserialize(from: dict) else {
                            return Observable.error(AppError.reason("获取验证码失败"))
                        }
                        LSLUser.current().refreshToken = token
                        LSLUser.current().token = token
                        return AuthAPI.requestMapBool(.MSMFetchCode(phone: phone!)).map { _ in () }
                    }
                } else {
                    return .error(AppError.reason("获取验证码失败"))
                }
            }
        })
        
        showPasswordAction = Action<Bool, Bool>(workFactory: { (isShow) -> Observable<Bool> in
            var isShow = isShow
            isShow = !isShow
            return .just(isShow)
        })
        
        regisForgetAction = Action<Input, Bool>(workFactory: { (p, c, pwd) -> Observable<Bool> in
            
            let validate = RegisAndRecoveryValidationService()
            let validatePhone = validate.validatePhone(p)
            let validateCode = validate.validateSMS(c)
            let validatePwd = validate.validatePwd(pwd)
            
            return Observable.combineLatest(validatePhone, validateCode, validatePwd).map { $0.0.isValid && $0.1.isValid && $0.2.isValid }.flatMapLatest { (isPass) -> Observable<Bool> in
                
                if isPass {
                    return AuthAPI.requestMapBool(.validatePhoneCode(phone: p!, code: c!)).flatMapLatest { (isValidate) -> Observable<Bool> in
                        if isValidate {
                            return AuthAPI.requestMapJSON(.getAccountInfoByPhone(phone: p!), classType: UserModel.self).flatMapLatest { (_) -> Observable<Bool> in
                                
                                return AuthAPI.requestMapJSON(.updateLoginPassword(password: pwd!.md5()), classType: UserModel.self).map { (user) -> Bool in
                                    LSLUser.current().user = user
                                    return true
                                }
                            }
                        } else {
                            return .error(AppError.reason("注册失败"))
                        }
                    }
                } else {
                    return .error(AppError.reason("注册失败"))
                }
            }
        })
    }
    
}
