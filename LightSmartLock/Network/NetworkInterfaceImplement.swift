//
//  NetworkInterfaceImplement.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import Alamofire
import CryptoSwift

extension AuthenticationInterface: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.shared.environment.host)!
    }
    
    var headers: [String : String]? {
        switch self {
        case .token, .userToken, .refreshUserToken, .refreshPlatformToken:
            return ["Content-Type": "x-www-form-urlencoded"]
        default:
            guard let tokenEntity = LSLUser.current().refreshToken, let type = tokenEntity.token_type, let token = tokenEntity.access_token else { return ["Content-Type": "application/json"] }
            return ["Authorization": type + " " + token]
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var path: String {
        
        switch self {
        case .login:
            return "api/User/LoginByPhoneAndPassword"
        case .token, .refreshPlatformToken, .refreshUserToken, .userToken:
            return "token"
        case .MSMFetchCode:
            return "api/User/SendMessage"
        case .validatePhoneCode:
            return "api/User/ValidatePhoneCode"
        case .getAccountInfoByPhone:
            return "/api/User/GetAccountInfoByPhone"
        case .updateLoginPassword:
            return "/api/User/UpdateAccountInfo/LoginPassword"
        }
    }
    
    var parameters: [String: Any]? {
        
        switch self {
        case .login(let phone, let password):
            return [
                "Phone": phone,
                "LoginPassword": password
            ]
            
        case .token:
            return [
                "username": "app_ios_01",
                "password": "522e355e827ab49137a36001418aade0",
                "grant_type": "password"
            ]
            
        case .MSMFetchCode(let phone):
            
            let firstIndex = phone.index(phone.startIndex, offsetBy: 4)
            let lastIndex = phone.index(phone.endIndex, offsetBy: -4)
            
            let firstFour = phone[..<firstIndex]
            let center    = phone[firstIndex..<lastIndex]
            let lastFoure = phone[lastIndex...]
            
            let secretOrigin = lastFoure + center + firstFour
            
            let md5          = secretOrigin.data(using: .utf8)!.md5()
            
            let params: [String: Any] = [
                "Phone": phone,
                "SecretCode": md5.toHexString()
            ]
            return params
            
        case .updateLoginPassword(let password):
            guard let userId = LSLUser.current().user?.accountID else { return nil }
            return ["AccountID": userId, "LoginPassword": password]
            
        case .validatePhoneCode(let phone, let code):
            return ["Phone": phone,
                    "Code": code]
            
        case .getAccountInfoByPhone(let phone):
            return ["Phone": phone]
            
        case .userToken(let userName, let pwd):
            return [
                "username": userName,
                "password": pwd,
                "grant_type": "password"
            ]
            
        case .refreshUserToken:
            guard let retoken = LSLUser.current().token?.refresh_token else {
                return [
                    "username": "app_ios_01",
                    "password": "522e355e827ab49137a36001418aade0",
                    "grant_type": "password"
                ]
            }
            return ["grant_type": "refresh_token",
                    "refresh_token": retoken]
            
        default: return nil
        }
    }
    
    var task: Task {
        let requestParameters = parameters ?? [:]
        let encoding: ParameterEncoding
        switch self.method {
        case .post:
            if self.path == "token" {
                encoding = URLEncoding.default
            } else {
                encoding = JSONEncoding.default
            }
        default:
            encoding = URLEncoding.default
        }
        return .requestParameters(parameters: requestParameters, encoding: encoding)
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data(base64Encoded: "业务测试数据") ?? Data()
        }
    }
}
