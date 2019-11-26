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
import PKHUD

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
                "LoginPassword": password.md5()
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



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


extension BusinessInterface: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.shared.environment.host)!
    }
    
    var headers: [String : String]? {
        guard let entiy = LSLUser.current().token else { return nil }
        
        guard let type = entiy.token_type, let token = entiy.access_token else {
            return nil
        }
        return  ["Authorization": type + " " + token]
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "api/File/UploadImage"
        case .getCustomerSceneList:
            return "api/Scene/GetCustomerSceneList"
        case .getCurrentCustomerInfo:
            return "api/Scene/GetCurrentCustomerInfo"
        case .getLockInfoBySceneID:
            return "api/Lock/GetLockInfoBySceneID"
        case .getLockCurrentInfoFromIOTPlatform:
            return "api/Lock/GetLockCurrentInfoFromIOTPlatform"
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        
        let requestParameters = parameters ?? [:]
        var encoding: ParameterEncoding = JSONEncoding.default
        
        switch self {
        case .uploadImage(let img, let description):
            
            let dateString = Date().description
            let index = dateString.index(dateString.startIndex, offsetBy: 10)
            
            if let data = img.jpegData(compressionQuality: 0.7) {
                let imgData = MultipartFormData(provider: .data(data), name: "file", fileName: String(dateString[..<index]), mimeType: "image/jpeg")
                let descriptionData = MultipartFormData(provider: .data(description.data(using: .utf8)!), name: description)
                let multipartData = [imgData, descriptionData]
                return .uploadMultipart(multipartData)
                
            } else if let data = img.pngData() {
                let imgData = MultipartFormData(provider: .data(data), name: "file", fileName: String(dateString[..<index]), mimeType: "image/png")
                let descriptionData = MultipartFormData(provider: .data(description.data(using: .utf8)!), name: description)
                let multipartData = [imgData, descriptionData]
                return .uploadMultipart(multipartData)
            }
            
            return .requestParameters(parameters: requestParameters, encoding: encoding)
            
        default:
            if self.method == .get {
                encoding = URLEncoding.default
                return .requestParameters(parameters: requestParameters, encoding: encoding)
            }
            return .requestParameters(parameters: requestParameters, encoding: encoding)
        }
    }
    
    var parameters: [String: Any]? {
        
        switch self {
        case let .getCustomerSceneList(pageIndex, pageSize, Sort):
            guard let accountId = LSLUser.current().user?.accountID else {
                HUD.flash(.label("无法获取 accountID"), delay: 2)
                return nil
            }
            
            return  ["AccountID": accountId,
                     "PageIndex": pageIndex,
                     "PageSize": pageSize ?? 5,
                     "Sort": Sort ?? 1]
            
        case .getCurrentCustomerInfo(let sceneID):
            guard let accountID = LSLUser.current().user?.accountID else { return nil }
            var param: [String: Any] = ["AccountID": accountID]
            
            if let sID = LSLUser.current().scene?.sceneID {
                param.updateValue(sID, forKey: "SceneID")
            } else {
                param.updateValue(sceneID, forKey: "SceneID")
            }
            return param
            
        case .getLockInfoBySceneID:
            guard let sceneId = LSLUser.current().scene?.sceneID else { return nil }
            return ["SceneID": sceneId]
            
        case .getLockCurrentInfoFromIOTPlatform:
            guard let sceneId = LSLUser.current().scene?.sceneID else { return  nil }
            return ["SceneID": sceneId]
        default:
            return nil
        }
    }
}
