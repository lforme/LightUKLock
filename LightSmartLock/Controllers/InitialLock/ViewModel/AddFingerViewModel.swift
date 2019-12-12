//
//  AddFingerViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import Action

final class AddFingerViewModel {
    
    var startAction: Action<Void, Bool>!
    
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
        
        self.startAction = Action<Void, Bool>(workFactory: {[unowned self] (_) -> Observable<Bool> in
            
            BluetoothPapa.shareInstance.scanForPeripherals(true)
            
            self.timer.take(15).subscribe(onNext: {[weak self] (_) in
                if BluetoothPapa.shareInstance.isConnected() {
                    self?.obConnected.onNext(true)
                    self?.obConnected.onCompleted()
                }
                }, onCompleted: {[weak self] in
                    if !BluetoothPapa.shareInstance.isConnected() {
                        self?.obConnected.onError(AppError.reason("没有找到蓝牙门锁"))
                    }
            }).disposed(by: self.disposeBag)
            
            return self.obConnected
        })
    }
    
    
    func addFinger() -> Observable<(Int?, String?)> {
        guard let userCode = LSLUser.current().userInScene?.userCode else {
            return .error(AppError.reason("无法从服务器获取用户编号, 请稍后再试"))
        }
        
        return Observable<(Int?, String?)>.create { (observer) -> Disposable in
            
            BluetoothPapa.shareInstance.addFinger(userNumber: userCode) { (data) in
                let dict = BluetoothPapa.serializeAddFinger(data)
                let step = dict?["步骤"] as? String
                let pwdNumer = dict?["密码编号"] as? String
                observer.onNext((Int(step ?? "0"), pwdNumer))
                if step == "4" {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
