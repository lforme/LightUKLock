//
//  DigitalChangePwdViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PKHUD

final class DigitalChangePwdViewModel: BluetoothViewModel {
    
    enum ModifyType: Int {
        case bluetooth = 0
        case cloudServer
    }
    
    let modifyType = BehaviorRelay<ModifyType>(value: .bluetooth)
    let newPassword = BehaviorRelay<String?>(value: nil)
    
    var shareConnected: Observable<Bool> {
        return startConnected.share(replay: 1, scope: .forever)
    }
    
    var saveAction: Action<String, Bool>!
    fileprivate let oldPassword: String
    
    init(oldPassword: String) {
        self.oldPassword = oldPassword
        super.init()
        
        shareConnected.subscribe(onNext: { (connected) in
            if connected {
                BluetoothPapa.shareInstance.handshake { (_) in
                    print("握手中")
                }
            }
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: disposeBag)
        
        let saveEnable = newPassword.map { $0?.count == 6 }
        
        saveAction = Action<String, Bool>(enabledIf: saveEnable, workFactory: {[unowned self] (pwd) -> Observable<Bool> in
            switch self.modifyType.value {
            case .bluetooth:
                guard let userCode = LSLUser.current().scene?.lockUserAccount else {
                    HUD.flash(.label("服务器没有返回用户编号, 请稍后再试"), delay: 2)
                    return .empty()
                }
                if !self.isConnected {
                    return .empty()
                }
                
                return self.changePassword(oldPassword: oldPassword, newPassword: pwd, userCode: userCode).flatMapLatest {[unowned self] (changeSuccessful) -> Observable<Bool> in
                    if changeSuccessful {
                        return self.updateToServer()
                    } else {
                        return .just(false)
                    }
                }
                
            case .cloudServer:
                return BusinessAPI.requestMapBool(.updateCustomerCodeKey(secret: pwd, isRemote: true))
            }
        })
    }
}


private extension DigitalChangePwdViewModel {
    
    func updateToServer() -> Observable<Bool> {
        
        guard let lockId = LSLUser.current().scene?.ladderLockId else {
            return .error(AppError.reason("无法获取门锁编号"))
        }
        
        return BusinessAPI.requestMapBool(.addAndModifyDigitalPassword(lockId: lockId, password: self.newPassword.value!, operationType: self.modifyType.value.rawValue + 1))
    }
    
    func changePassword(oldPassword: String, newPassword: String, userCode: String) -> Observable<Bool> {
        
        return Observable<Bool>.create { (observer) -> Disposable in
            BluetoothPapa.shareInstance.resetUserPasswordBy(userNumber: userCode, oldPassword: oldPassword, newPassword: newPassword) { (data) in
                let result = BluetoothPapa.serializeResetUserPassword(data)
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
