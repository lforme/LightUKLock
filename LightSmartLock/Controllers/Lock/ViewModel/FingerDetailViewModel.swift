//
//  FingerDetailViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Action
import PKHUD

final class FingerDetailViewModel: BluetoothViewModel {
    
    let fingerId: String
    let fingerNum: String
    
    var shareConnected: Observable<Bool> {
        return startConnected.share(replay: 1, scope: .forever)
    }
    
    let isForceFinger = BehaviorRelay<Bool>(value: false)
    let forcePhone = BehaviorRelay<String?>(value: nil)
    let isRemote = BehaviorRelay<Bool>(value: false)
    
    var saveAction: Action<Void, Bool>!
    
    init(id: String, fingerNum: String) {
        self.fingerNum = fingerNum
        self.fingerId = id
        super.init()
        
        self.shareConnected.subscribe(onNext: { (connect) in
            if connect {
                BluetoothPapa.shareInstance.handshake { (_) in
                    print("握手成功")
                }
            }
        }).disposed(by: self.disposeBag)
        
        self.saveAction = Action<Void, Bool>(workFactory: {[unowned self] (_) -> Observable<Bool> in
            if !self.isConnected {
                return .error(AppError.reason("未连接到蓝牙门锁, 请稍后再试"))
            }
            return self.setForceFinger(self.isForceFinger.value)
        })
    }
    
    func deleteFinger() -> Observable<Bool> {
        
        guard let userCode = LSLUser.current().userInScene?.userCode else {
            return .error(AppError.reason("无法从服务器获取用户编号, 请稍后再试"))
        }
        
        if isRemote.value {
            return BusinessAPI.requestMapBool(.deleteFingerPrintKey(id: self.fingerId, isRemote: true))
        } else {
            return Observable.create {[unowned self] (observer) -> Disposable in
                if !self.isConnected {
                    observer.onError(AppError.reason("没有连接到蓝牙门锁, 请稍后再试"))
                }
                BluetoothPapa.shareInstance.deleteFinger(userNumber: userCode, pwdNumber: self.fingerNum) {[unowned self] (_) in
                    
                    BusinessAPI.requestMapBool(.deleteFingerPrintKey(id: self.fingerId, isRemote: false)).subscribe().disposed(by: self.disposeBag)
                    
                    observer.onNext(true)
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }
    }
    
    func setFingerName(_ name: String) -> Observable<Bool> {
        return BusinessAPI.requestMapBool(.setFingerRemark(id: self.fingerId, fingerName: name))
    }
}

private extension FingerDetailViewModel {
    
    func setForceFinger(_ isOn: Bool) -> Observable<Bool> {
        
        guard let userCode = LSLUser.current().userInScene?.userCode else {
            return .error(AppError.reason("无法从服务器获取用户编号, 请稍后再试"))
        }
        
        return Observable<(String, String)>.create {[unowned self] (observer) -> Disposable in
            if isOn {
                BluetoothPapa.shareInstance.changeForceFinger(userNumber: userCode, fingerNumber: self.fingerNum) { (data) in
                    
                    let dict = BluetoothPapa.serializeChangeForceFinger(data)
                    guard let userNum = dict?["用户编号"] as? String, let fNum = dict?["指纹编号"] as? String else {
                        observer.onError(AppError.reason("设置胁迫指纹失败, 请稍后再试"))
                        return
                    }
                    observer.onNext((userNum, fNum))
                    observer.onCompleted()
                }
            } else {
                observer.onError(AppError.reason("若要取消胁迫指纹, 请直接删除指纹"))
            }
            return Disposables.create()
            
        }.flatMapLatest {[unowned self] (arg) -> Observable<Bool> in
            guard let phone = self.forcePhone.value else {
                HUD.flash(.label("请输入正确的手机号码"), delay: 2)
                return .empty()
            }
            
            let (uCode, fCode) = arg
            print("用户编号", uCode)
            print("指纹编号", fCode)
            return BusinessAPI.requestMapBool(.setFingerCoercionReminPhone(id: self.fingerId, phone: phone))
        }
    }
}
