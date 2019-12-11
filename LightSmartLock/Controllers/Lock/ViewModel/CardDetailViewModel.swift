//
//  CardDetailViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CardDetailViewModel: BluetoothViewModel {
    
    enum DeleteWay: Int {
        case bluetooth = 0
        case remote
    }
    
    let keyNumber: String
    let keyId: String
    
    var shareConnected: Observable<Bool> {
        return self.startConnected.share(replay: 1, scope: .forever)
    }
    
    init(keyNumber: String, keyId: String) {
        self.keyNumber = keyNumber
        self.keyId = keyId
        super.init()
        
        shareConnected.subscribe(onNext: { (connect) in
            if connect {
                BluetoothPapa.shareInstance.handshake { (data) in
                    print(data ?? "握手失败")
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func deleteCard(way: DeleteWay) -> Observable<Bool> {
        switch way {
        case .bluetooth:
            return Observable<Bool>.create {[weak self] (observer) -> Disposable in
                guard let this = self else {
                    return Disposables.create()
                }
                if !this.isConnected {
                    observer.onError(AppError.reason("蓝牙未连接成功, 请稍后再试"))
                }
                
                guard let userCode = LSLUser.current().userInScene?.userCode else {
                    return Disposables.create()
                }
                
                BluetoothPapa.shareInstance.deleteCard(userNumber: userCode, keyNumber: this.keyNumber) { (data) in
                    let dict = BluetoothPapa.serializeDeleteUser(data)
                    guard let success = dict?["成功"] as? Bool else {
                        observer.onError(AppError.reason("删除门卡失败"))
                        return
                    }
                    observer.onNext(success)
                    observer.onCompleted()
                }
                
                return Disposables.create()
            }.flatMapLatest {[unowned self] (deleteSuccess) -> Observable<Bool> in
                if deleteSuccess {
                    return BusinessAPI.requestMapBool(.deleteCustomerCard(keyId: self.keyId))
                } else {
                    return .error(AppError.reason("删除门卡失败"))
                }
            }
            
        case .remote:
            return BusinessAPI.requestMapBool(.deleteCustomerCard(keyId: self.keyId))
        }
    }
    
    func changeCardName(_ name: String) -> Observable<Bool> {
        return BusinessAPI.requestMapBool(.setCardRemark(keyId: self.keyId, remark: name))
    }
}
