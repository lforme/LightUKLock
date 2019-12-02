//
//  BluetoothViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PKHUD

class BluetoothViewModel {
    
    var startConnected: Observable<Bool> {
        return obConnected.asObserver()
    }
    
    var isConnected: Bool {
        return BluetoothPapa.shareInstance.isConnected()
    }
    
    var disposeBag = DisposeBag()
    
    private let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).share(replay: 1, scope: .forever)
    
    private let obConnected = BehaviorSubject<Bool>(value: BluetoothPapa.shareInstance.isConnected())
    
    deinit {
        BluetoothPapa.shareInstance.scanForPeripherals(false)
    }
    
    init() {
        
        BluetoothPapa.shareInstance.checkBluetoothState { (state) in
            if state == .poweredOff {
                HUD.flash(.label("检测到蓝牙处于关闭状态\n请先开启蓝牙"), delay: 2)
            }
        }
        
        BluetoothPapa.shareInstance.scanForPeripherals(true)
        
        timer.take(15).subscribe(onNext: {[weak self] (_) in
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
        }).disposed(by: disposeBag)
        
        BluetoothPapa.shareInstance.peripheralsScanResult { (peripherals) in
            guard let peripheral = peripherals.last else {
                return
            }
            if BluetoothPapa.shareInstance.isConnected() {
                return
            }
            BluetoothPapa.shareInstance.connect(peripheral: peripheral)
        }
    }
}
