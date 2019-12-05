//
//  HomeViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action


protocol HomeViewModeling {
    
    var isInstallLock: Observable<Bool> { get }
    
    var userInScene: Observable<UserInSceneModel> { get }
    var lockInfo: Observable<SmartLockInfoModel> { get }
    var lockIOTInfo: Observable<IOTLockInfoModel> { get }
    var unlockRecord: Observable<[UnlockRecordModel]> { get }
}

final class HomeViewModel: HomeViewModeling {
    
    var isInstallLock: Observable<Bool>
    
    var userInScene: Observable<UserInSceneModel>
    var lockInfo: Observable<SmartLockInfoModel>
    var lockIOTInfo: Observable<IOTLockInfoModel>
    var unlockRecord: Observable<[UnlockRecordModel]>
    
    let disposeBag = DisposeBag()
    
    init() {
        
        let requset = BusinessAPI.requestMapJSONArray(.getCustomerSceneList(pageIndex: 1, pageSize: 5, Sort: 1), classType: SceneListModel.self, useCache: true).catchErrorJustReturn([LSLUser.current().scene])
        
        let networkHasLock = requset.map { (sceneList) -> Bool in
            let noOptionSceneList = sceneList.compactMap { $0 }
            if noOptionSceneList.count == 0 {
                return false
            }
            let count = noOptionSceneList.filter { $0.IsInstallLock ?? false }.count
            if count == 0 {
                return false
            } else {
                if LSLUser.current().scene == nil {
                    LSLUser.current().scene = noOptionSceneList.filter { $0.IsInstallLock ?? false }.first
                }
                return true
            }
        }
       
        isInstallLock = Observable.combineLatest(networkHasLock, Observable.just(LSLUser.current().isInstalledLock)).map{ $0.0 || $0.1 }
        
        let shareSceneListModel = LSLUser.current().obScene.share(replay: 1, scope: .forever)
        
        self.userInScene = shareSceneListModel.flatMapLatest { (scene) -> Observable<UserInSceneModel> in
            guard let model = scene, let sceneId = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            
            return BusinessAPI.requestMapJSON(.getCurrentCustomerInfo(sceneID: sceneId), classType: UserInSceneModel.self, useCache: true)
        }
        
        self.lockInfo = shareSceneListModel.flatMapLatest { (scene) -> Observable<SmartLockInfoModel> in
            guard let model = scene, let _ = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            return BusinessAPI.requestMapJSON(.getLockInfoBySceneID, classType: SmartLockInfoModel.self, useCache: true)
        }
        
        self.lockIOTInfo = shareSceneListModel.flatMapLatest { (scene) -> Observable<IOTLockInfoModel> in
            guard let model = scene, let _ = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            return BusinessAPI.requestMapJSON(.getLockCurrentInfoFromIOTPlatform, classType: IOTLockInfoModel.self, useCache: true)
        }
        
        self.unlockRecord = shareSceneListModel.flatMapLatest({ (scene) -> Observable<[UnlockRecordModel]> in
            guard let model = scene, let _ = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            guard let userCode = LSLUser.current().userInScene?.userCode else {
                return .error(AppError.reason("无法从服务器获取user code"))
            }
            
            return BusinessAPI.requestMapJSONArray(.getUnlockLog(userCodes: [userCode], beginTime: nil, endTime: nil, index: 1, pageSize: 5), classType: UnlockRecordModel.self, useCache: true).map { (models) -> [UnlockRecordModel] in
                return models.compactMap { $0 }
            }
        })
        
    }
    
}
