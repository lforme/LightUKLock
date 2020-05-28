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
    
    // 租客获取资产下的合同列表
    case getTenantContracts(assetId: String)
    
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
    
    //查询水电气记录
    case getUtilitiesRecords(assetId: String, year: Int, type: UtilitiesType)
    
    // 添加水电气抄表
    case addUtilitiesRecord(assetId: String, model: AddUtilitiesRecordModel)
    
    // 身份证照OCR识别
    case recognizeIDCard(url: String)
    
    // 新增租客（创建租客合同
    case addNewTenantContractInfo(info: TenantContractInfo)
    
    // 获取下载地址
    case getDownloadAddress
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
             .getTenantContracts,
             .getAssetContracts,
             .getStatistics,
             .getFacilities,
             .getFacilityList,
             .getDownloadAddress:
            
            return .get
            
        case .saveFacilities,
             .addFacility,
             .getUtilitiesRecords,
             .addUtilitiesRecord,
             .recognizeIDCard,
             .addNewTenantContractInfo:
            return .post
            
        case .deleteFacility:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .getAssetContract:
            return "/tenant_contract_info/asset_contract"
        case .getTenantContracts:
            return "/tenant_contract_info/tenant_contracts"
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
        case .getUtilitiesRecords(assetId: let assetId, _, _):
            return "/ladder_utilities_record/utilities/records/\(assetId)"
        case .addUtilitiesRecord(assetId: let assetId, _):
            return "/ladder_utilities_record/utilities/\(assetId)"
        case .recognizeIDCard:
            return "/common/ocr"
        case .addNewTenantContractInfo:
            return "/tenant_contract_info/"
        case .getDownloadAddress:
            return "/common/download/address"
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
            
        case .getAssetContracts(assetId: let assetId),
             .getTenantContracts(assetId: let assetId):
            return .requestParameters(parameters: ["assetId": assetId], encoding: URLEncoding.queryString)
            
        case .getStatistics,
             .getFacilities,
             .getFacilityList,
             .deleteFacility,
             .getDownloadAddress:
            return .requestPlain
            
        case .saveFacilities(_, models: let models):
            let param = ["jsonArray": models.toJSON()]
            return .requestParameters(parameters: param, encoding: JsonArrayEncoding.default)
            
        case .addFacility(assetId: let assetId, name: let name):
            let param = ["ladderAssetHouseId": assetId,
                         "facilityName": name]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .getUtilitiesRecords(_, year: let year, type: let type):
            let param = ["year": year,
                         "type": type.rawValue]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case .addUtilitiesRecord(_, model: let model):
            return .requestParameters(parameters: model.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .recognizeIDCard(url: let url):
            return .requestParameters(parameters: ["imageUrl": url], encoding: URLEncoding.queryString)
        case .addNewTenantContractInfo(info: let info):
            return .requestParameters(parameters: info.toJSON() ?? [:], encoding: JSONEncoding.default)
        }
    }
}
