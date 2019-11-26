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
}

final class HomeViewModel: HomeViewModeling {
    
    var isInstallLock: Observable<Bool>
    
    var userInScene: Observable<UserInSceneModel>
    var lockInfo: Observable<SmartLockInfoModel>
    var lockIOTInfo: Observable<IOTLockInfoModel>
    
    let disposeBag = DisposeBag()
    
    init() {
        
        let requset = BusinessAPI.requestMapJSONArray(.getCustomerSceneList(pageIndex: 1, pageSize: 3, Sort: 1), classType: SceneListModel.self, useCache: true).catchErrorJustReturn([])
        
        let networkHasLock = requset.map { (sceneList) -> Bool in
            let noOptionSceneList = sceneList.compactMap { $0 }
            if noOptionSceneList.count == 0 {
                return false
            }
            let count = noOptionSceneList.filter { $0.IsInstallLock }.count
            if count == 0 {
                return false
            } else {
                LSLUser.current().scene = noOptionSceneList.filter { $0.IsInstallLock }.first
                return true
            }
        }
        
        isInstallLock = Observable.combineLatest(networkHasLock, Observable.just(LSLUser.current().isInstalledLock)).map{ $0.0 && $0.1 }
        
        let shareSceneListModel = LSLUser.current().obScene.share(replay: 1, scope: .forever)
        
        self.userInScene = shareSceneListModel.flatMapLatest { (listModel) -> Observable<UserInSceneModel> in
            guard let model = listModel, let sceneId = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            
            return BusinessAPI.requestMapJSON(.getCurrentCustomerInfo(sceneID: sceneId), classType: UserInSceneModel.self, useCache: true)
            
        }
        
        self.lockInfo = shareSceneListModel.flatMapLatest { (listModel) -> Observable<SmartLockInfoModel> in
            guard let model = listModel, let _ = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            return BusinessAPI.requestMapJSON(.getLockInfoBySceneID, classType: SmartLockInfoModel.self, useCache: true)
        }
        
        self.lockIOTInfo = shareSceneListModel.flatMapLatest { (listModel) -> Observable<IOTLockInfoModel> in
            guard let model = listModel, let _ = model.sceneID else {
                return .error(AppError.reason("无法从服务器获取场景ID"))
            }
            return BusinessAPI.requestMapJSON(.getLockCurrentInfoFromIOTPlatform, classType: IOTLockInfoModel.self, useCache: true)
        }
    }
    
    
}
