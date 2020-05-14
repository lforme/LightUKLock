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
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verificationCode: return .get
        case .logout: return .delete
        default:
            return .post
        }
    }
    
    var path: String {
        
        switch self {
        case .login:
            return "/login/login"
        case .verificationCodeValid:
            return "/common/verification_code/valid"
        case let .verificationCode(phone):
            return "/common/verification_code/\(phone)"
        case .registeriOS:
            return "/login/register/ios"
        case .forgetPasswordiOS:
            return "/login/forget_password/ios"
        case let .refreshToken(token):
            return "/login/refresh_token/\(token)"
        case let .logout(token):
            return "/login/logtou/\(token)"
        }
    }
    
    var parameters: [String: Any]? {
        
        switch self {
        case let .login(phone, password):
            return [
                "phone": phone,
                "password": password
            ]
        case let .registeriOS(phone, password, msmCode):
            return ["password": password, "phone": phone, "verificationCode": msmCode]
            
        case let .forgetPasswordiOS(phone, password, msmCode):
            return ["password": password, "phone": phone, "verificationCode": msmCode]
            
        case let .verificationCodeValid(code, phone):
            return ["phone": phone, "verificationCode": code]
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
        
        guard let token = entiy.accessToken, let type = entiy.tokenType else {
            return nil
        }
        return ["Authorization": type + token]
    }
    
    var method: Moya.Method {
        switch self {
        case .user,
             .getHouses,
             .getAssetHouseDetail,
             .getLockInfo,
             .getHomeInfo,
             .getUserList,
             .getCustomerSysRoleTips,
             .getAllOpenWay,
             .reportAsset,
             .tenantContractInfoAssetContract,
             .reportReportItems,
             .costCategory,
             .tenantContractInfo,
             .checkTerminationTenantContract:
            return .get
            
        case .deleteAssetHouse,
             .forceDeleteLock,
             .deleteCard,
             .deleteFinger,
             .undoTempPassword,
             .deleteBillInfo:
            return .delete
            
        case .editUser,
             .editCardOrFingerName,
             .setAlarmFingerprint:
            return .put
            
        default:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/attachments"
        case .user:
            return "/user"
        case .getHouses:
            return "/ladder_asset_house/houses"
        case let .deleteAssetHouse(id):
            return "/ladder_asset_house/house/\(id)"
        case let .getAssetHouseDetail(id):
            return "/ladder_asset_house/house/\(id)"
        case .editAssetHouse:
            return "/ladder_asset_house/house"
        case .addLock:
            return "/ladder_lock/lock"
        case let .getLockInfo(id):
            return "/ladder_lock/info/\(id)"
        case let .getHomeInfo(id):
            return "/ladder_lock/home/\(id)"
        case let .forceDeleteLock(id):
            return "/ladder_lock/lock/\(id)"
        case .getUserList:
            return "/user/list"
        case let .uploadOpenDoorRecord(lockId, _, _):
            return "/ladder_open_lock_record/record/\(lockId)"
        case .addUserByBluethooth:
            return "/user"
        case .getCustomerSysRoleTips:
            return "/user/kinsfolk_config"
        case .editUser:
            return "/user"
        case let .deleteUserBy(id):
            return "/user/\(id)"
        case let .getAllOpenWay(lockId):
            return "/ladder_lock/pwd/list/\(lockId)"
        case let .addCard(lockId, _, _):
            return "/ladder_card_figura/pwd/card/\(lockId)"
        case let .editCardOrFingerName(id, _):
            return "/ladder_card_figura/pwd/name/\(id)"
        case let .deleteCard(id, _):
            return "/ladder_card_figura/pwd/card/\(id)"
        case let .addFinger(lockId, _, _, _):
            return "/ladder_card_figura/pwd/finger_print/\(lockId)"
        case let .deleteFinger(id, _):
            return "/ladder_card_figura/pwd/finger_print/\(id)"
        case let .setAlarmFingerprint(id, _, _):
            return "/ladder_card_figura/pwd/finger_print/\(id)"
        case .addAndModifyDigitalPassword:
            return "/ladder_number_password/pwd/number"
        case let .getTempPasswordList(lockId, _, _):
            return "/ladder_tmp_password/pwd/tmps/\(lockId)"
        case let .getTempPasswordLog(id):
            return "/ladder_tmp_password/pwd/tmp/record/\(id)"
        case let .undoTempPassword(id):
            return "/ladder_tmp_password/pwd/tmp/record/\(id)"
        case let .addTempPassword(lockId, _):
            return "/ladder_tmp_password/pwd/tmp/\(lockId)"
        case let .getUnlockRecords(lockId, _, _, _):
            return "/ladder_open_lock_record/records/\(lockId)"
        case .reportAsset:
            return "/report/asset_report"
        case .baseTurnoverInfoList:
            return "/base_turnover_info/list"
        case .tenantContractInfoAssetContract:
            return "/tenant_contract_info/asset_contract"
        case .reportReportItems:
            return "/report/report_items"
        case .baseTurnoverInfo:
            return "/base_turnover_info/"
        case .costCategory:
            return "/cost_category/"
        case let .tenantContractInfo(contractId):
            return "/tenant_contract_info/\(contractId)"
        case let .checkTerminationTenantContract(contractId):
            return "/tenant_contract_info/termination/check/\(contractId)"
        case .terminationContract:
            return "/tenant_contract_info/termination"
        case .billInfoClearing:
            return "/base_bill_info/clearing"
        case let .deleteBillInfo(billId):
            return "/base_bill_info/\(billId)"
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
       
        case let .editAssetHouse(parameter):
            return parameter.toJSON()
            
        case let .addLock(parameter):
            return parameter.toJSON()
            
        case let .getUserList(lockId, pageIndex, pageSize):
            return ["currentPage": pageIndex, "pageSize": pageSize ?? 15, "ladderLockId": lockId]
            
        case let .uploadOpenDoorRecord(_, time, type):
            return ["openTime": time, "openType": type]
            
        case let .addUserByBluethooth(parameter):
            return parameter.toJSON()
            
        case let .editUser(parameter):
            return parameter.toJSON()
            
        case let .addCard(_, keyNum, name):
            return ["keyNum": keyNum, "name": name]
            
        case let .editCardOrFingerName(_, name):
            return ["name": name]
            
        case let .deleteCard(_, operationType):
            return ["operationType": operationType]
            
        case let .addFinger(_, keyNum, name, phone):
            var dic: [String: Any] = [:]
            if let p = phone {
                dic.updateValue(p, forKey: "phone")
            }
            dic.updateValue(keyNum, forKey: "keyNum")
            dic.updateValue(name, forKey: "name")
            return dic
            
        case let .deleteFinger(_, operationType):
            return ["operationType": operationType]
            
        case let .setAlarmFingerprint(_, phone, operationType):
            return ["operationType": operationType, "phone": phone]
            
        case let .addAndModifyDigitalPassword(lockId, password, operationType):
            return ["ladderLockId": lockId, "operationType": operationType, "password": password]
            
        case let .getTempPasswordList(_, pageIndex, pageSize):
            return ["currentPage": pageIndex, "pageSize": pageSize ?? 15]
         
        case let .addTempPassword(_, parameter):
            return parameter.toJSON()
            
        case let .getUnlockRecords(_, type, pageIndex, pageSize):
            return ["currentPage": pageIndex, "pageSize": pageSize ?? 15, "type": type]
            
        case let .reportAsset(assetId, year):
            return ["assetId": assetId, "year": year]
            
        case let .baseTurnoverInfoList(assetId, year):
            return ["assetId": assetId, "year": year]
            
        case let .tenantContractInfoAssetContract(assetId, year):
            return ["assetId": assetId, "year": year]
            
        case let .reportReportItems(assetId, costId):
            return ["assetId": assetId, "costCategoryId": costId]
            
        case let .baseTurnoverInfo(assetId, contractId, payTime, itemList):
            let array = itemList.toJSON().compactMap { $0 }
            
            return ["assetId": assetId, "contractId": contractId, "payTime": payTime, "turnoverItemDTOList": array]
            
        case let .terminationContract(billId, accountType, clearDate):
            return ["accountType": accountType, "billId": billId, "clearDate": clearDate]
            
        case let .billInfoClearing(assetId, contractId, startDate, endDate):
            return ["assetId": assetId, "contractId": contractId, "startDate": startDate, "endDate": endDate]
            
        default:
            return nil
        }
    }
}


struct JsonArrayEncoding: Moya.ParameterEncoding {
    
    public static var `default`: JsonArrayEncoding { return JsonArrayEncoding() }
    
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var req = try urlRequest.asURLRequest()
        let json = try JSONSerialization.data(withJSONObject: parameters!["jsonArray"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json
        return req
    }
    
}
