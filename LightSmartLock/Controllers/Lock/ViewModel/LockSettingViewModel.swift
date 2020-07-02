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
                HUD.hide()
                BluetoothPapa.shareInstance.handshake { (data) in
                    print(data ?? "握手失败")
                }
            } else {
                print("正在连接蓝牙")
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
            return .empty()
        }
        guard let id = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁Id"), delay: 2)
            return .empty()
        }
        
        if buttonIndex == 0 {
            
            return Observable<Bool>.create {[unowned self] (observer) -> Disposable in
                
                
                BluetoothPapa.shareInstance.factoryReset { (data) in
                    
                    BluetoothPapa.shareInstance.removeAESkey()
                    BluetoothPapa.shareInstance.cancelPeripheralConnection()
                    
                    BusinessAPI.requestMapBool(.forceDeleteLock(id: id)).subscribe(onNext: { (res) in
                        observer.onNext(res)
                        observer.onCompleted()
                    }, onError: { (error) in
                        observer.onError(error)
                    }, onCompleted: {
                        observer.onCompleted()
                    }).disposed(by: self.disposeBag)
                }
                
                return Disposables.create()
            }
            
        } else {
            return .empty()
        }
    }
    
}
