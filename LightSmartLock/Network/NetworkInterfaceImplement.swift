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

extension AMapAPI: TargetType {
    
    var path: String {
        switch self {
        case .searchByKeyWords: return "/place/around"
        }
    }
    
    var method: Moya.Method { return .get }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        let requestParameters = parameters ?? [:]
        let encoding: ParameterEncoding = URLEncoding.default
        return .requestParameters(parameters: requestParameters, encoding: encoding)
    }
    
    var baseURL: URL { return URL(string: "http://restapi.amap.com/v3")! }
    
    var headers: [String : String]? { return ["Content-Type": "application/json"] }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchByKeyWords(let keywords, let currentLoction, let index):
            
            var param: [String: Any] = ["types": 120000, "radius": 0, "offset": 20, "xtensions": "all", "key": PlatformKey.gouda]
            param.updateValue(keywords, forKey: "keywords")
            param.updateValue("\(currentLoction.0),\(currentLoction.1)", forKey: "location")
            param.updateValue(index, forKey: "page")
            return param
        }
    }
}

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
            
        case .updateLoginPassword(let password, let accountId):
            return ["AccountID": accountId, "LoginPassword": password]
            
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
        case .getUnlockLog:
            return "api/Lock/GetUnlockLog"
        case .updateUserInfo:
            return "api/User/UpdateAccountInfo"
        case .submitBluthUnlockOperation:
            return "api/Lock/SubmitBluthUnlockOperation"
        case .getLockNotice:
            return "api/Lock/GetLockNotice"
        case .unInstallLock:
            return "api/Lock/UnInstallLock"
        case .getSceneAssets:
            return "api/Scene/GetSceneAssets"
        case .addOrUpdateSceneAsset:
            return "api/Scene/AddOrUpdateSceneAssets"
        case .deleteSceneAssetsBySceneId:
            return "api/Scene/DeleteSceneAssetsBySceneID"
        case .uploadLockConfigInfo:
            return "api/Lock/UploadLockConfigInfo"
        case .getCustomerMemberList:
            return "api/CustomerMember/GetCustomerMemberList"
        case .getCustomerKeyFirst:
            return "api/Key/GetCustomerKeyFirst"
        case .getKeyStatusChangeLogByKeyId:
            return "api/Key/GetKeyStatusChangeLogByKeyId"
        case .updateCustomerCodeKey:
            return "api/Key/UpdateCustomerCodeKey"
        case .getFingerPrintKeyList:
            return "api/FingerPrint/GetFingerPrintKeyList"
        case .setFingerCoercionReminPhone:
            return "api/FingerPrint/SetFingerCoercionReminPhone"
        case .setFingerCoercionToNormal:
            return "api/FingerPrint/SetFingerCoercionToNormal"
        case .setFingerRemark:
            return "api/FingerPrint/SetFingerRemark"
        case .deleteFingerPrintKey:
            return "api/FingerPrint/DeleteFingerPrintKey"
        case .addFingerPrintKey:
            return "api/FingerPrint/AddFingerPrintKey"
        case .getCustomerKeyList:
            return "api/Key/GetCustomerKeyList"
        case .addCustomerCard:
            return "api/Card/AddCustomerCard"
        case .setCardRemark:
            return "api/Card/SetCardRemark"
        case .deleteCustomerCard:
            return "api/Card/DeleteCustomerCard"
        case .getCustomerSysRoleTips:
            return "api/CustomerMember/GetCustomerSysRoleTips"
        case .addCustomerMember:
            return "api/CustomerMember/AddCustomerMember"
        case .updateCustomerNameById:
            return "api/CustomerMember/UpdateCustomerNameById"
        case .deleteCustomerMember:
            return "api/CustomerMember/DeleteCustomerMember"
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
            
        case let .getCurrentCustomerInfo(sceneID):
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
            
        case let .getUnlockLog(userCodes, beginTime, endTime, index, pageSize):
            guard let sceneId = LSLUser.current().scene?.sceneID else { return nil }
            var dict: [String: Any] = ["SceneID": sceneId, "UserCode": userCodes, "PageIndex": index]
            
            if let begin = beginTime {
                dict.updateValue(begin, forKey: "BeginTime")
            }
            if let end = endTime {
                dict.updateValue(end, forKey: "EndTime")
            }
            if let size = pageSize {
                dict.updateValue(size, forKey: "PageSize")
            }
            
            return dict
            
        case let .updateUserInfo(info):
            return info.toJSON()
            
        case .submitBluthUnlockOperation:
            guard let customerId = LSLUser.current().userInScene?.customerID else { return nil }
            return ["CustomerID": customerId]
            
        case let .getLockNotice(noticeTypes, noticeLevels, pageIndex, pageSize):
            
            guard let customerId = LSLUser.current().userInScene?.customerID, let lockId = LSLUser.current().lockInfo?.customerLockID else {
                return nil
            }
            let param: [String: Any] = ["CustomerID": customerId,
                                        "CustomerLockID": lockId,
                                        "noticeType": noticeTypes,
                                        "noticeLevel": noticeLevels,
                                        "pageIndex": pageIndex,
                                        "PageSize": pageSize ?? 15]
            return param
            
        case .unInstallLock:
            guard let sceneId = LSLUser.current().scene?.sceneID else { return nil }
            return ["SceneID": sceneId]
            
        case .getSceneAssets:
            guard let sceneId = LSLUser.current().scene?.sceneID else { return nil }
            return ["SceneID": sceneId]
            
        case let .addOrUpdateSceneAsset(parameter):
            guard let accountId = LSLUser.current().user?.accountID else {
                return nil
            }
            var param = parameter.toJSON()
            param?.updateValue(accountId, forKey: "accountID")
            return param
            
        case let .deleteSceneAssetsBySceneId(id):
            return ["SceneID": id]
            
        case let .uploadLockConfigInfo(info):
            return info.toJSON()
            
        case let .getCustomerMemberList(pageIndex, pageSize):
            guard let accountId = LSLUser.current().user?.accountID, let sceneId = LSLUser.current().scene?.sceneID else {
                return nil
            }
            return ["AccountID": accountId, "SceneID": sceneId, "PageIndex": pageIndex, "PageSize": pageSize ?? 15]
            
        case let .getCustomerKeyFirst(type):
            guard let customerId = LSLUser.current().userInScene?.customerID else {
                return nil
            }
            return ["CustomerID": customerId, "KeyType": type]
            
        case let .getKeyStatusChangeLogByKeyId(keyID, index, pageSize):
            return ["KeyID": keyID, "PageIndex": index, "PageSize": pageSize ?? 15]
            
            
        case let .updateCustomerCodeKey(secret, isRemote):
            guard let customerId = LSLUser.current().userInScene?.customerID else {
                return nil
            }
            if let remote = isRemote {
                return ["CustomerID": customerId, "Secret": secret, "isRemote": remote]
            } else {
                return ["CustomerID": customerId, "Secret": secret]
            }
            
        case let .getFingerPrintKeyList(customerId, index, pageSize):
            guard let lockId = LSLUser.current().lockInfo?.customerLockID else {
                return nil
            }
            return ["CustomerID": customerId, "LockID": lockId, "PageSize":  pageSize ?? 15, "PageIndex": index]
            
        case let .setFingerCoercionReminPhone(id, phone):
            return ["KeyID": id, "Phone": phone]
            
        case let .setFingerCoercionToNormal(id):
            return ["KeyID": id]
            
        case let .setFingerRemark(id, fingerName):
            return ["KeyID": id, "Remark": fingerName]
            
        case let .deleteFingerPrintKey(id, isRemote):
            return ["KeyID": id, "isRemote": isRemote]
            
        case let .addFingerPrintKey(name):
            guard let userCode = LSLUser.current().userInScene?.userCode, let customerId = LSLUser.current().userInScene?.customerID, let lockId = LSLUser.current().lockInfo?.customerLockID, let keyId = LSLUser.current().userInScene?.pwdNumber else {
                return nil
            }
            return ["UserCode": userCode, "CustomerID": customerId, "LockID": lockId, "KeyNumber": keyId, "Remark": name]
            
        case let .getCustomerKeyList(keyType, index, pageSize):
            guard let customerId = LSLUser.current().userInScene?.customerID else { return nil }
            return ["CustomerID": customerId, "KeyType": keyType, "PageIndex": index, "PageSize": pageSize ?? 15]
            
        case let .addCustomerCard(KeyNumber, remark):
            guard let userCode = LSLUser.current().userInScene?.userCode, let customerId = LSLUser.current().userInScene?.customerID, let lockId = LSLUser.current().lockInfo?.customerLockID else {
                return nil
            }
            var dict: [String: Any] = ["UserCode": userCode, "CustomerID": customerId, "LockID": lockId, "KeyNumber": KeyNumber]
            if let name = remark {
                dict.updateValue(name, forKey: "Remark")
            }
            return dict
            
        case let .setCardRemark(keyId, remark):
            return ["KeyID": keyId, "Remark": remark]
            
        case let .deleteCustomerCard(keyId):
            return ["KeyID": keyId]
            
        case let .addCustomerMember(member):
            
            var param = member.toJSON()
            if let customerId = LSLUser.current().userInScene?.customerID {
                param?.updateValue(customerId, forKey: "CustomerId")
            }
            return param
            
        case let .updateCustomerNameById(id, name):
            return ["customerID": id, "customerNickName": name]
            
        case let .deleteCustomerMember(id, isRemote):
            if let remote = isRemote {
                return ["customerID": id, "isRemote": remote]
            }
            return ["customerID": id]
            
        default:
            return nil
        }
    }
}
