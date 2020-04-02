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
    case getLockCurrentInfoFromIOTPlatform // 从物联网平台获取门锁信息
    case getUnlockLog // 解锁记录
}

extension TodayExtensionInterface: TargetType {
    var baseURL: URL {
        return URL(string: ServerHost.shared.environment.host)!
    }
    
    var headers: [String : String]? {
        
        let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
        let jsonStr = shareDefault?.string(forKey: ShareUserDefaultsKey.token.rawValue)
        
        guard let entiy = AccessTokenModel.deserialize(from: jsonStr) else { return nil }
        
        guard let token = entiy.access_token else {
            return nil
        }
        return ["Authorization": token]
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getLockCurrentInfoFromIOTPlatform:
            return "api/Lock/GetLockCurrentInfoFromIOTPlatform"
        case .getUnlockLog:
            return "api/Lock/GetUnlockLog"
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
            
        case .getLockCurrentInfoFromIOTPlatform:
            let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
            let sceneStr = shareDefault?.string(forKey: ShareUserDefaultsKey.scene.rawValue)
            guard let sceneId = SceneListModel.deserialize(from: sceneStr)?.sceneID else { return  nil }
            return ["SceneID": sceneId]
            
        case .getUnlockLog:
            let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
            let sceneStr = shareDefault?.string(forKey: ShareUserDefaultsKey.scene.rawValue)
            let userStr = shareDefault?.string(forKey: ShareUserDefaultsKey.userInScene.rawValue)
            guard let sceneId = SceneListModel.deserialize(from: sceneStr)?.sceneID, let userCode = UserInSceneModel.deserialize(from: userStr)?.userCode else { return  nil }
            
            return ["SceneID": sceneId, "UserCode": [userCode], "PageIndex": 1, "PageSize": 3]
            
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

