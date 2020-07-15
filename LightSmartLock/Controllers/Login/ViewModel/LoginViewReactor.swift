//
//  LoginViewReactor.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import HandyJSON

final class LoginViewReactor: Reactor {
    
    let validationService = LoginValidationService()
    
    enum Action {
        case phonePasswordChanged(String, String)
        case showPassword(Bool)
        case login
    }
    
    struct State {
        var phone: String
        var password: String
        var validationResult: LoginValidationResult
        var showPassword: Bool
        var loginResult: Bool?
        var loginError: AppError?
    }
    
    enum Mutation {
        case setPhonePassword(String, String)
        case setValidationResult(LoginValidationResult)
        case setLoginResult(Bool?, AppError?)
        case setShowPassword(Bool)
    }
    
    let initialState: State
    
    init() {
        self.initialState = State(phone: "", password: "", validationResult: .empty, showPassword: false, loginResult: nil, loginError: nil)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .phonePasswordChanged(phone, pwd):
            return Observable.concat([
                Observable.just(.setPhonePassword(phone, pwd)),
                validationService.validatePhone(phone, password: pwd).map(Mutation.setValidationResult)
            ])
            
        case let .showPassword(show):
            return .just(.setShowPassword(show))
            
        case .login:
            let p = self.currentState.phone.replacingOccurrences(of: " ", with: "")
            
            let getUser = AuthAPI.requestMapJSON(.login(userName: p, password: self.currentState.password), classType: AccessTokenModel.self).flatMapLatest { token -> Observable<UserModel> in
                
                LSLUser.current().token = token
                LSLUser.current().refreshToken = token
                
                return BusinessAPI.requestMapJSON(.user, classType: UserModel.self)
            }
            
            return Observable.concat([
                Observable.just(Mutation.setLoginResult(nil, nil)),
                getUser.map({ (user) -> Mutation in
                    if user.id == nil {
                        return Mutation.setLoginResult(false, AppError.reason("无法获取用户信息"))
                    }
                    LSLUser.current().isFirstLogin = true
                    LSLUser.current().user = user
                    return Mutation.setLoginResult(true, nil)
                }).catchError({ (error) -> Observable<Mutation> in
                    if let e = error as? AppError {
                        return .just(.setLoginResult(false, e))
                    } else {
                        return .just(.setLoginResult(false, AppError.reason(error.localizedDescription)))
                    }
                })
            ])
        }
    }
    
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setPhonePassword(phone, pwd):
            state.phone = phone
            state.password = pwd
            state.loginResult = nil
            state.loginError = nil
            
        case let .setLoginResult(result, error):
            state.loginError = error
            state.loginResult = result
            
        case let .setShowPassword(show):
            state.showPassword = show
            
        case let .setValidationResult(validate):
            state.validationResult = validate
            
        }
        
        return state
    }
}
