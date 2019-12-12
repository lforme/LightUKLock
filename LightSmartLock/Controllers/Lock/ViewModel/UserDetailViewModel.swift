//
//  UserDetailViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class UserDetailViewModel: BluetoothViewModel {
    
    enum DeleteWay: Int {
        case bluetooth = 0
        case remote
    }
    
    private let userModel: UserMemberListModel
    
    init(userModel: UserMemberListModel) {
        self.userModel = userModel
        super.init()
        
        self.startConnected.subscribe(onNext: { (connect) in
            if connect {
                BluetoothPapa.shareInstance.handshake { (_) in
                    print("握手成功")
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    
    func changeUserName(_ name: String) -> Observable<Bool> {
        guard let id = userModel.customerID else {
            return .error(AppError.reason("无法从服务器获取用户Id, 请稍后再试"))
        }
        return BusinessAPI.requestMapBool(.updateCustomerNameById(id: id, name: name))
    }
    
    func deleteUser(way: DeleteWay) -> Observable<Bool> {
        guard let customerId = userModel.customerID, let oldPassword = userModel.initialSecret, let userCode = userModel.userCode else {
            return .error(AppError.reason("无法从服务器获取删除用户所必须的信息, 请稍后再试"))
        }
        
        switch way {
        case .bluetooth:
            
            return Observable<Bool>.create {[unowned self] (observer) -> Disposable in
                if !self.isConnected {
                    observer.onError(AppError.reason("蓝牙未连接成功, 请稍后再试"))
                }
                BluetoothPapa.shareInstance.deleteUserBy(oldPassword, userNumber: userCode) { (data) in
                    let result = BluetoothPapa.serializeDeleteUser(data)
                    print(result ?? "")
                    observer.onNext(true)
                    observer.onCompleted()
                }
                return Disposables.create()
            }.do(onNext: {[unowned self] (success) in
                if success {
                    self.updateDeletInto(customerId: customerId, isRemote: false).subscribe().disposed(by: self.disposeBag)
                }
            })
            
        case .remote:
            return self.updateDeletInto(customerId: customerId, isRemote: true)
        }
    }
    
    private func updateDeletInto(customerId: String, isRemote: Bool?) -> Observable<Bool> {
        return BusinessAPI.requestMapBool(.deleteCustomerMember(customerID: customerId, isRemote: isRemote))
    }
    
}
