//
//  LockSettingViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import Action

final class LockSettingViewModel: BluetoothViewModel {
    
    var shareConnected: Observable<Bool> {
        return startConnected.share(replay: 1, scope: .forever)
    }
    
    override init() {
        super.init()
        
        shareConnected.subscribe(onNext: { (connect) in
            if connect {
                BluetoothPapa.shareInstance.handshake { (data) in
                    print(data ?? "握手失败")
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func setVolume(_ volume: Int) {
        
        if self.isConnected {
            BluetoothPapa.shareInstance.setVoice(volume: volume) { (data) in
                print(BluetoothPapa.serializeGetVolume(data) ?? "设置声音失败")
            }
        }
    }
    
    func forceDeleteLock(_ buttonIndex: Int) -> Observable<Bool> {
        
        guard let id = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁Id"), delay: 2)
            return .empty()
        }
        
        if buttonIndex == 0 {
            return BusinessAPI.requestMapBool(.forceDeleteLock(id: id))
        } else {
            return .empty()
        }
    }
    
    func deleteLock(_ buttonIndex: Int) -> Observable<Bool> {
        
        if !self.isConnected {
            HUD.flash(.label("蓝牙未连接到门锁"), delay: 2)
            return .empty()
        }

        guard let id = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁Id"), delay: 2)
            return .empty()
        }
        
        if buttonIndex == 0 {
            return BusinessAPI.requestMapBool(.forceDeleteLock(id: id)).flatMapLatest { (requestSuccess) -> Observable<Bool> in
                
                return Observable<Bool>.create { (observer) -> Disposable in
                    
                    if requestSuccess {
                        BluetoothPapa.shareInstance.factoryReset { (data) in
                            BluetoothPapa.shareInstance.removeAESkey()
                            BluetoothPapa.shareInstance.cancelPeripheralConnection()
                        }
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
        } else {
            return .empty()
        }
    }
    
}
