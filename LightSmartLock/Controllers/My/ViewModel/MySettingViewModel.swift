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
        return BusinessAPI.requestMapJSON(.updateUserInfo(info: userInfo), classType: UserModel.self)
    }
    
    func changePassword(_ password: String) -> Observable<UserModel> {
        guard var userInfo = LSLUser.current().user else {
            return .error(AppError.reason("获取本地用户失败"))
        }
        userInfo.loginPassword = password
        return BusinessAPI.requestMapJSON(.updateUserInfo(info: userInfo), classType: UserModel.self)
    }
    
    func changeNickname(_ name: String) -> Observable<UserModel> {
        guard var userInfo = LSLUser.current().user else {
            return .error(AppError.reason("获取本地用户失败"))
        }
        userInfo.userName = name
        return BusinessAPI.requestMapJSON(.updateUserInfo(info: userInfo), classType: UserModel.self)
    }
    
    func changeUserAvatar(_ image: UIImage) -> Observable<UserModel> {
        return self.uoloadImage(image).flatMapLatest { (url) -> Observable<UserModel> in
            guard var userInfo = LSLUser.current().user else {
                return .error(AppError.reason("获取本地用户失败"))
            }
            userInfo.headPic = url
            return BusinessAPI.requestMapJSON(.updateUserInfo(info: userInfo), classType: UserModel.self)
        }
    }
    
    func verify(isSupport: @escaping (Bool)->Void, block: @escaping (Bool)->Void) {
        let laContext = LAContext()
        laContext.localizedFallbackTitle = nil
        var error : NSError?
        let support = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if support {
            laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证您的身份") { (success, er) in
                DispatchQueue.main.async {
                    if let e = er {
                        print(e.localizedDescription)
                    } else {
                        block(success)
                    }
                }
            }
        }
        isSupport(support)
    }
    
    private func uoloadImage(_ image: UIImage) -> Observable<String?> {
        return BusinessAPI.requestMapAny(.uploadImage(image, description: "头像上传")).map { (res) -> String? in
            let json = res as? [String: Any]
            let headPicUrl = json?["Data"] as? String
            return headPicUrl
        }
    }
}
