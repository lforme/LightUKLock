//
//  RegisViewReactor.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

final class RegisViewReactor: Reactor {
    
    let validation = RegisAndRecoveryValidationService()
    
    enum Action {
        case phoneChanged(String)
        case getCode
        case codeChanged(String)
        case passwordChanged(String)
        case register
    }
    
    struct State {
        var phone: String
        var code: String
        var password: String
        var phoneValidationResult: LoginValidationResult
        var codevValidationResult: LoginValidationResult
        var pwdValidationResult: LoginValidationResult
        var registerResult: Bool?
        var registerError: AppError?
        var getCodeError: AppError?
    }
    
    enum Mutation {
        case setPhone(String)
        case setPhoneValidationResult(LoginValidationResult)
        case setCode(String)
        case setFetchCodeResult(Bool?)
        case setCodeValidationResult(LoginValidationResult)
        case setPwd(String)
        case setPwdValidationResult(LoginValidationResult)
        case setRegisterResult(Bool?, AppError?)
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(phone: "", code: "", password: "", phoneValidationResult: .empty, codevValidationResult: .empty, pwdValidationResult: .empty, registerResult: nil, registerError: nil, getCodeError: nil)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .phoneChanged(phone):
            return Observable.concat([
                Observable.just(.setPhone(phone)),
                validation.validatePhone(phone).map(Mutation.setPhoneValidationResult)
            ])
            
        case .getCode:
            return AuthAPI.requestMapAny(.token).flatMapLatest { (json) -> Observable<Mutation> in
                let dict = json as? [String: Any]
                guard let token = AccessTokenModel.deserialize(from: dict) else {
                    return Observable.just(Mutation.setFetchCodeResult(false))
                }
                LSLUser.current().token = token
                return AuthAPI.requestMapBool(.MSMFetchCode(phone: self.currentState.phone)).map { Mutation.setFetchCodeResult($0) }
            }
            
        case let .codeChanged(code):
            return Observable.concat([
                Observable.just(.setCode(code)),
                validation.validateSMS(code).map(Mutation.setCodeValidationResult)
            ])
            
        case let .passwordChanged(pwd):
            return Observable.concat([
                Observable.just(.setPwd(pwd)),
                validation.validatePwd(pwd).map(Mutation.setPwdValidationResult)
            ])
            
        case .register:
            
            return AuthAPI.requestMapBool(.validatePhoneCode(phone: self.currentState.phone, code: self.currentState.code)).flatMapLatest { (result) -> Observable<Mutation> in
                if result {
                    return AuthAPI.requestMapJSON(.updateLoginPassword(password: self.currentState.password), classType: UserModel.self).map { (user) -> Mutation in
                        LSLUser.current().user = user
                        return Mutation.setRegisterResult(true, nil)
                    }
                } else {
                    return .just(Mutation.setRegisterResult(false, AppError.reason("注册失败")))
                }
            }.catchError { (error) -> Observable<Mutation> in
                if let e = error as? AppError {
                    return .just(.setRegisterResult(false, e))
                } else {
                    return .just(.setRegisterResult(false, AppError.reason(error.localizedDescription)))
                }
            }
        }
    }
    
}
