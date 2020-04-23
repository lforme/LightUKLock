//
//  AddCardViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import Action

final class AddCardViewModel {
    
    var startScanAction: Action<Void, Bool>!
    
    private let disposeBag = DisposeBag()
    
    private let obConnected = BehaviorSubject<Bool>(value: BluetoothPapa.shareInstance.isConnected())
    private let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).share(replay: 1, scope: .forever)
    
    deinit {
        BluetoothPapa.shareInstance.scanForPeripherals(false)
    }
    
    init() {
        
        BluetoothPapa.shareInstance.checkBluetoothState { (state) in
            if state == .poweredOff {
                HUD.flash(.label("检测到蓝牙处于关闭状态\n请先开启蓝牙"), delay: 2)
            }
        }
        
        BluetoothPapa.shareInstance.peripheralsScanResult { (peripherals) in
            guard let peripheral = peripherals.last else {
                return
            }
            if BluetoothPapa.shareInstance.isConnected() {
                return
            }
            BluetoothPapa.shareInstance.connect(peripheral: peripheral)
        }
        
        self.startScanAction = Action<Void, Bool>(workFactory: {[unowned self] (_) -> Observable<Bool> in
            
            BluetoothPapa.shareInstance.scanForPeripherals(true)
            
            self.timer.take(15).subscribe(onNext: {[weak self] (_) in
                if BluetoothPapa.shareInstance.isConnected() {
                    self?.obConnected.onNext(true)
                    self?.obConnected.onCompleted()
                }
                }, onCompleted: {[weak self] in
                    if BluetoothPapa.shareInstance.isConnected() {
                        self?.obConnected.onNext(true)
                        self?.obConnected.onCompleted()
                    } else {
                        self?.obConnected.onError(AppError.reason("没有找到蓝牙门锁"))
                    }
            }).disposed(by: self.disposeBag)
            
            return self.obConnected
        })
    }
    
    func addCard() -> Observable<String> {
        guard let userCode = LSLUser.current().scene?.lockUserAccount else {
            return .error(AppError.reason("服务器没有返回用户Id, 请稍后再试"))
        }
        return Observable<String>.create { (observer) -> Disposable in
            
            BluetoothPapa.shareInstance.addCard(userNumber: userCode) { (data) in
                let dict = BluetoothPapa.serializeAddCard(data)
                guard let keyNumber = dict?["密码编号"] as? String else {
                    observer.onError(AppError.reason("添加门卡失败, 请稍后再试"))
                    return
                }
                observer.onNext(keyNumber)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func setCardName(_ name: String, keyNumber: String) -> Observable<Bool> {
        
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            
            return .error(AppError.reason("无法获取门锁编号"))
        }
        
        return BusinessAPI.requestMapBool(.addCard(lockId: lockId, keyNum: keyNumber, name: name))
    }
}
