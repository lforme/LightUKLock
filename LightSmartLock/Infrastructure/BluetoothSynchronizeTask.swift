//
//  BluetoothSynchronizeTask.swift
//  IntelligentUOKO
//
//  Created by mugua on 2019/10/15.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Alamofire
import SwiftDate
import PKHUD


final class BluetoothSynchronizeTask: UKBluetoothManagerDelegate {
    
    typealias WriteResult = (String, Bool)
    
    var writeToBluethooth: Action<String, WriteResult>
    var end: Bool = true
    
    private let serverCommand = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    init() {
        
        writeToBluethooth = Action<String, WriteResult>(workFactory: { (commandFromBlue) -> Observable<WriteResult> in
            
            return Observable<WriteResult>.create { (obs) -> Disposable in
                
                BluetoothPapa.shareInstance.synchronizeTask(task: commandFromBlue) { (data) in
                    
                    if let blueResq = BluetoothPapa.serializeSynchronizeTask(data) {
                        
                        if blueResq != "010203040506070809" {
                            obs.onNext(WriteResult(blueResq, true))
                        } else {
                            obs.onNext(WriteResult(blueResq, false))
                        }
                        obs.onCompleted()
                        
                    } else {
                        obs.onError(AppError.reason("同步任务失败"))
                    }
                }
                return Disposables.create()
            }.delaySubscription(5, scheduler: MainScheduler.instance)
        })
    }
    
    func synchronizeTask() {
        BluetoothPapa.shareInstance.delegate = self
        
        serverCommand.subscribe(onNext: {[weak self] (s) in
            guard let this = self else { return }
            this.writeToBluethooth.execute(s)
        }).disposed(by: disposeBag)
        
        writeToBluethooth.elements.subscribe(onNext: {[weak self] (reslut) in
            guard let this = self else { return }
//            if reslut.1 {
//                this.fetchTask(param: reslut.0).subscribe().disposed(by: this.disposeBag)
//            }
            
        }).disposed(by: disposeBag)
        
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        
//        self.fetchTask(param: nil).subscribe().disposed(by: self.disposeBag)
        
    }
//
//    private func fetchTask(param: String?) -> Observable<String> {
//
//        return Observable<String>.create { (obs) -> Disposable in
//            let headers: HTTPHeaders = ["Content-Type": "application/json"]
//
//            if let p = param {
//                Alamofire.request("http://deviceapi.jinriwulian.com/api/IOTDeviceAPI/APPGet", method: HTTPMethod.get, parameters: ["strMessageData": p, "DevType": "kf110"], encoding: URLEncoding.default, headers: headers).responseJSON {[weak self] (response) in
//                    let dict = response.value as? [String: Any]
//                    if let taskStr = dict?["Data"] as? String {
//                        self?.serverCommand.onNext(taskStr)
//                    }
//                }
//
//            } else {
//                if let macWithColon = LSLUser.current().lockInfo?.blueMac {
//                    let mac = macWithColon.replacingOccurrences(of: ":", with: "")
//                    let date = Date().toString(.custom("yyyyMMddHHmm"))
//                    let paramBuilder = ["strMessageData": "FF00030108\(mac)00100662640000\(date)", "DevType": "kf110"]
//
//                    Alamofire.request("http://deviceapi.jinriwulian.com/api/IOTDeviceAPI/APPGet", method: HTTPMethod.get, parameters: paramBuilder, encoding: URLEncoding.default, headers: headers).responseJSON {[weak self] (response) in
//
//                        let dict = response.value as? [String: Any]
//                        if let taskStr = dict?["Data"] as? String {
//                            self?.serverCommand.onNext(taskStr)
//                        }
//                    }
//
//                } else {
//                    obs.onError(AppError.reason("无法获取蓝牙Mac地址信息"))
//                }
//            }
//
//            return Disposables.create()
//        }
//
//    }
    
}
