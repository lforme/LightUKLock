//
//  MySettingViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PKHUD
import LocalAuthentication

final class MySettingViewModel {
    
    init() {}
    
    func changePhone(_ phone: String) -> Observable<UserModel> {
        guard var userInfo = LSLUser.current().user else {
            return .error(AppError.reason("获取本地用户失败"))
        }
        userInfo.phone = phone
        return BusinessAPI.requestMapBool(.editUser(parameter: userInfo)).map { _ in userInfo }
    }
    
    func changePassword(_ password: String) -> Observable<UserModel> {
        guard var userInfo = LSLUser.current().user else {
            return .error(AppError.reason("获取本地用户失败"))
        }
        userInfo.loginPassword = password
        return BusinessAPI.requestMapBool(.editUser(parameter: userInfo)).map { _ in userInfo }
    }
    
    func changeNickname(_ name: String) -> Observable<UserModel> {
        guard var userInfo = LSLUser.current().user else {
            return .error(AppError.reason("获取本地用户失败"))
        }
        
        userInfo.nickname = name
        return BusinessAPI.requestMapBool(.editUser(parameter: userInfo)).map { _ in userInfo }
    }
    
    func changeUserAvatar(_ image: UIImage) -> Observable<UserModel> {
        return self.uoloadImage(image).flatMapLatest { (url) -> Observable<UserModel> in
            guard var userInfo = LSLUser.current().user else {
                return .error(AppError.reason("获取本地用户失败"))
            }
            userInfo.avatar = url
            print(userInfo)
            return BusinessAPI.requestMapBool(.editUser(parameter: userInfo)).map { _ in userInfo }
        }
    }
    
    func verify() -> Observable<(isSupport: Bool, isVerify: Bool)> {
        return Observable.create { (observer) -> Disposable in
            let laContext = LAContext()
            laContext.localizedFallbackTitle = "验证失败"
            laContext.localizedCancelTitle = "取消验证"
            var error : NSError?
            let support = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if support {
                laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证您的身份") { (success, er) in
                    DispatchQueue.main.async {
                        if let e = er {
                            print(e.localizedDescription)
                            observer.onNext((isSupport: true, isVerify: false))
                            observer.onCompleted()
                        } else {
                            observer.onNext((isSupport: true, isVerify: true))
                            observer.onCompleted()
                        }
                    }
                }
            } else {
                observer.onNext((isSupport: false, isVerify: false))
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    
    private func uoloadImage(_ image: UIImage) -> Observable<String?> {
        return BusinessAPI.requestMapAny(.uploadImage(image, description: "头像上传")).map { (res) -> String? in
            let json = res as? [String: Any]
            let headPicUrl = json?["data"] as? String
            return headPicUrl
        }
    }
}
