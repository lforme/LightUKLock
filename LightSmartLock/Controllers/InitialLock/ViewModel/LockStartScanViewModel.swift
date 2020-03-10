//
//  LockStartScanViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Action
import RxCocoa
import RxSwift
import PKHUD

final class LockStartScanViewModel {
    
    var scanAction: Action<Void, Bool>!
    
    private let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).share(replay: 1, scope: .forever)
    
    var disposeBag = DisposeBag()
    
    deinit {
        BluetoothPapa.shareInstance.scanForPeripherals(false)
    }
    
    init() {
        BluetoothPapa.shareInstance.checkBluetoothState { (state) in
            if state == .poweredOff {
                HUD.flash(.label("检测到蓝牙处于关闭状态\n请先开启蓝牙"), delay: 2)
            }
        }
    }
    
    func setupAction() {
        self.scanAction = Action<Void, Bool>(workFactory: {[weak self] (_) -> Observable<Bool> in
            guard let this = self else {
                return .empty()
            }
            
            return Observable.create { (observer) -> Disposable in
                BluetoothPapa.shareInstance.removeAESkey()
                BluetoothPapa.shareInstance.scanForPeripherals(true)
                BluetoothPapa.shareInstance.peripheralsScanResult { (peripherals) in
                    guard let peripheral = peripherals.last else {
                        return
                    }
                    if BluetoothPapa.shareInstance.isConnected() {
                        return
                    }
                    BluetoothPapa.shareInstance.connect(peripheral: peripheral)
                }
                
                this.timer.take(15).subscribe(onNext: { (_) in
                    if BluetoothPapa.shareInstance.isConnected() {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }, onCompleted: {
                    if BluetoothPapa.shareInstance.isConnected() {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onError(AppError.reason("没有找到蓝牙门锁"))
                    }
                }).disposed(by: this.disposeBag)
                
                return Disposables.create()
            }
        })
    }
}
