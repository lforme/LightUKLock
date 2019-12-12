//
//  AddUserViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PKHUD

final class AddUserViewModel: BluetoothViewModel {
    
    enum AddWay {
        case bluetooth
        case remote
    }
    
    var userTags: Observable<[String]> {
        return _userTags.asObservable()
    }
    
    var displayModel: Observable<AddUserMemberModel> {
        return _submitModel.asObservable()
    }
    
    var saveAtion: Action<AddUserMemberModel, Bool>!
    
    var addWay: AddWay = .bluetooth
    
    let nickname = BehaviorRelay<String?>(value: nil)
    let phone = BehaviorRelay<String?>(value: nil)
    
    private let _userTags = BehaviorRelay<[String]>(value: [])
    private var _submitModel = BehaviorRelay<AddUserMemberModel>(value: AddUserMemberModel())
    
    init(id: String) {
        super.init()
        
        self.startConnected.subscribe(onNext: { (connected) in
            if connected {
                BluetoothPapa.shareInstance.handshake { (data) in
                    print(data ?? "握手失败")
                }
            }
        }).disposed(by: disposeBag)
        
        var localModel = self._submitModel.value
        localModel.SceneID = id
        localModel.OperationType = 0
        self._submitModel.accept(localModel)
        
        BusinessAPI.requestMapAny(.getCustomerSysRoleTips).map { (data) -> [String] in
            guard let dict = data as? [String: Any], let tagArray = dict["Data"] as? [String] else {
                return []
            }
            return tagArray
        }.catchErrorJustReturn([]).bind(to: _userTags).disposed(by: disposeBag)
        
        nickname.subscribe(onNext: {[weak self] (nick) in
            guard let this = self else { return }
            var localModel = this._submitModel.value
            localModel.CustomerNickName = nick
            this._submitModel.accept(localModel)
            
        }).disposed(by: disposeBag)
        
        phone.subscribe(onNext: {[weak self] (p) in
            guard let this = self else { return }
            var localModel = this._submitModel.value
            localModel.Phone = p
            this._submitModel.accept(localModel)
            
        }).disposed(by: disposeBag)
        
        self.saveAtion = self.addAction()
    }
    
    func pickUserAvatar(_ image: UIImage) {
        return BusinessAPI.requestMapAny(.uploadImage(image, description: "头像上传")).map { (res) -> String? in
            let json = res as? [String: Any]
            let headPicUrl = json?["Data"] as? String
            return headPicUrl
        }.subscribe(onNext: {[unowned self] (avatarUrl) in
            var localModel = self._submitModel.value
            localModel.HeadPic = avatarUrl
            self._submitModel.accept(localModel)
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: disposeBag)
    }
    
    func setTag(_ roleTag: String) {
        var localModel = self._submitModel.value
        localModel.Label = roleTag
        self._submitModel.accept(localModel)
    }
    
    func setPassword() {
        let array = Array(0...9)
        let random = array.shuffled()[0..<6].map { String($0) }
        let pwd = random.joined()
        var localModel = self._submitModel.value
        localModel.InitialSecret = pwd
        self._submitModel.accept(localModel)
    }
    
    func setAddWay(_ way: Int) {
        var localModel = self._submitModel.value
        localModel.OperationType = way
        self._submitModel.accept(localModel)
    }
    
    private func addAction() -> Action<AddUserMemberModel, Bool> {
    
        return Action<AddUserMemberModel, Bool> {[weak self] (_) -> Observable<Bool> in
            guard let this = self else {
                return .empty()
            }
            
            let localModel = this._submitModel.value
            
            guard localModel.InitialSecret.isNotNilNotEmpty, localModel.Label.isNotNilNotEmpty, localModel.Phone.isNotNilNotEmpty, localModel.CustomerNickName.isNotNilNotEmpty else {
                
                return .error(AppError.reason("请检查必填项是否输入完整"))
            }
            
            
            switch this.addWay {
            case .bluetooth:
                return Observable.create { (observer) -> Disposable in
                    
                    if !this.isConnected {
                        observer.onError(AppError.reason("未连接到蓝牙门锁, 请稍后再试"))
                    }
                    BluetoothPapa.shareInstance.addUserBy(this._submitModel.value.InitialSecret!) { (data) in
                        let dict = BluetoothPapa.serializeAddUser(data)
                        if let userCode = dict?["用户编号"] as? String {
                            var localModel = this._submitModel.value
                            localModel.UserCode = userCode
                            this._submitModel.accept(localModel)
                            observer.onNext(true)
                            observer.onCompleted()
                        } else {
                            observer.onError(AppError.reason("添加用户失败"))
                        }
                    }
                    return Disposables.create()
                }.do(onNext: {(success) in
                    if success {
                        BusinessAPI.requestMapBool(.addCustomerMember(member: this._submitModel.value)).subscribe(onNext: { (s) in
                            if !s {
                                BluetoothPapa.shareInstance.deleteUserBy(this._submitModel.value.InitialSecret!, userNumber: this._submitModel.value.UserCode!) { (data) in
                                    print(data ?? "", "网络请求失败删除门锁用户")
                                }
                            }
                        }, onError: { (e) in
                            print(e)
                            BluetoothPapa.shareInstance.deleteUserBy(this._submitModel.value.InitialSecret!, userNumber: this._submitModel.value.UserCode!) { (data) in
                                print(data ?? "", "网络请求失败删除门锁用户")
                            }
                        }).disposed(by: this.disposeBag)
                    }
                })
                
            case .remote:
                return BusinessAPI.requestMapBool(.addCustomerMember(member: this._submitModel.value))
            }
        }
    }
}
