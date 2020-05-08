//
//  NetworkInterface.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON
import Moya

enum BusinessInterface2 {
    
    // 资产合同列表
    case getAssetContract(assetId: String, year: String)
    
    // 房东获取资产下的合同列表及账单列表
    case getAssetContracts(assetId: String)
    
    // 获取资产下的流水统计
    case getStatistics(assetId: String)
    
    // 查询资产配套
    case getFacilities(assetId: String)
    
    // 资产里添加/编辑/删除配套 传当前所有的最新的
    case saveFacilities(assetId: String, models: [LadderAssetFacilityVO])
    
    // 添加自定义配套
    case addFacility(assetId: String, name: String)
    
    // 查询配套（枚举+自定义）
    case getFacilityList(assetId: String)
    
    // 删除自定义配套
    case deleteFacility(id: String)
    
    
    
    
}


extension BusinessInterface2: TargetType {
    
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
        case .getAssetContract,
             .getAssetContracts,
             .getStatistics,
             .getFacilities,
             .getFacilityList:
            
            return .get
            
        case .saveFacilities,
             .addFacility:
            return .post
            
        case .deleteFacility:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .getAssetContract:
            return "/tenant_contract_info/asset_contract"
        case .getAssetContracts:
            return "/tenant_contract_info/asset_contracts"
        case .getStatistics(assetId: let assetId):
            return "/base_turnover_info/statistics/\(assetId)"
        case .getFacilities(assetId: let assetId),
             .saveFacilities(assetId: let assetId, _):
            return "/ladder_asset_facility/facility/\(assetId)"
        case .addFacility:
            return "/ladder_facility/facility"
        case .getFacilityList(assetId: let id):
            return "/ladder_facility/facility/\(id)"
        case .deleteFacility(id: let id):
            return "/ladder_facility/facility/\(id)"
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getAssetContract(assetId: let assetId, year: let year):
            let param = ["assetId": assetId,
                         "year": year]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
            
        case .getAssetContracts(assetId: let assetId):
            return .requestParameters(parameters: ["assetId": assetId], encoding: URLEncoding.queryString)
            
        case .getStatistics,
             .getFacilities,
             .getFacilityList,
             .deleteFacility:
            return .requestPlain
            
        case .saveFacilities(_, models: let models):
            let param = ["jsonArray": models.toJSON()]
            return .requestParameters(parameters: param, encoding: JsonArrayEncoding.default)
            
        case .addFacility(assetId: let assetId, name: let name):
            let param = ["ladderAssetHouseId": assetId,
                         "facilityName": name]
            return .requestParameters(parameters: param, encoding: URLEncoding.httpBody)
        }
    }
}
