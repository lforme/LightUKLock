//
//  WidgetNetwork.swift
//  LSLWidget
//
//  Created by mugua on 2020/1/2.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import Moya

enum TodayExtensionInterface {
    case getUnlockRecords(lockId: String)
    case getLockInfo(lockId: String) // 门锁信息
}

extension TodayExtensionInterface: TargetType {
    var baseURL: URL {
        return URL(string: ServerHost.shared.environment.host)!
    }
    
    var headers: [String : String]? {
        
        let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
        let jsonStr = shareDefault?.string(forKey: ShareUserDefaultsKey.token.rawValue)
        
        guard let entiy = AccessTokenModel.deserialize(from: jsonStr) else { return nil }
        
        guard let token = entiy.accessToken else {
            return nil
        }
        return ["Authorization": token]
    }
    
    var method: Moya.Method {
        switch self {
        case .getLockInfo:
            return .get
        case .getUnlockRecords:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case let .getLockInfo(lockId):
            return "/ladder_lock/info/\(lockId)"
        case let .getUnlockRecords(lockId):
            return "/ladder_open_lock_record/records/\(lockId)"
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getLockInfo:
            return nil
            
        case .getUnlockRecords:
            return ["currentPage": 1, "pageSize": 15, "type": 3]
        }
    }
    
    var task: Task {
        let requestParameters = parameters ?? [:]
        var encoding: ParameterEncoding = JSONEncoding.default
        
        if self.method == .get {
            encoding = URLEncoding.default
            return .requestParameters(parameters: requestParameters, encoding: encoding)
        }
        return .requestParameters(parameters: requestParameters, encoding: encoding)
    }
}

