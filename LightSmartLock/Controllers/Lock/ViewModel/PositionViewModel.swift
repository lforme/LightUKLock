//
//  PositionViewModel.swift
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

final class PositionViewModel {
    
    enum ButtonType {
        case delete
        case save
    }
    
    var buttonType: Observable<ButtonType> {
        return obButtonType.asObservable()
    }
    
    var defaultPositionModel: Observable<PositionModel?> {
        return Observable.merge(obPositionModel.asObservable(), _obPositionModel.asObservable())
    }
    
    var id: String?
    
    private let obPositionModel = BehaviorSubject<PositionModel?>(value: nil)
    private let obButtonType = BehaviorRelay<ButtonType>(value: .save)
    private let obVillageName = BehaviorRelay<String?>(value: nil)
    let obArea = BehaviorRelay<String?>(value: nil)
    private let obHouseType = BehaviorRelay<String?>(value: nil)
    private let obTowards = BehaviorRelay<String?>(value: nil)
    private let obDoorplate = BehaviorRelay<String?>(value: nil)
    private let obUnit = BehaviorRelay<String?>(value: nil)
    private let obCity = BehaviorRelay<String?>(value: nil)
    private let obRegion = BehaviorRelay<String?>(value: nil)
    private let obBuilding = BehaviorRelay<String?>(value: nil)
    
    private let _obPositionModel = BehaviorRelay<PositionModel?>(value: nil)
    private var disposeBag = DisposeBag()
    
    init(id: String?) {
        self.id = id
        
        let getAssetHouseDetail = BusinessAPI.requestMapJSON(.getAssetHouseDetail(id: self.id ?? ""), classType: PositionModel.self).share(replay: 1, scope: .forever).catchErrorJustReturn(PositionModel())
        
        Observable.combineLatest(obVillageName.asObservable(), obArea.asObservable(), obHouseType.asObservable(), obTowards.asObservable(), obDoorplate, obUnit.asObservable(), obCity.asObservable(), obRegion.asObservable()).subscribe(onNext: {[weak self] (_) in
            self?.obButtonType.accept(.save)
        }).disposed(by: disposeBag)
        
        getAssetHouseDetail.bind(to: obPositionModel).disposed(by: disposeBag)
        
        getAssetHouseDetail.subscribe(onNext: {[weak self] (model) in
            self?._obPositionModel.accept(model)
        }).disposed(by: disposeBag)
        
        obArea.subscribe(onNext: {[weak self] (area) in
            var param = self?._obPositionModel.value
            param?.area = Double(area ?? "")
            self?._obPositionModel.accept(param)
        }).disposed(by: disposeBag)
        
        getAssetHouseDetail.subscribe(onCompleted: {[weak self] in
            self?.obButtonType.accept(.delete)
        }).disposed(by: disposeBag)
    }
    
    func setupPosition(_ village: String?, city: String?, region: String?) {
        obVillageName.accept(village)
        obCity.accept(city)
        obRegion.accept(region)
        var model = _obPositionModel.value
        model?.buildingName = village
        model?.address = region
        _obPositionModel.accept(model)
    }
    
    func setupHouseType(_ type: String?) {
        obHouseType.accept(type)
        var model = _obPositionModel.value
        model?.houseStruct = type
        _obPositionModel.accept(model)
    }
    
    func setupTowards(_ towards: String?) {
        obTowards.accept(towards)
        let model = _obPositionModel.value
        _obPositionModel.accept(model)
    }
    
    func setupBuildingInfo(_ building: String?, uniti: String?, doorPlate: String?) {
        obBuilding.accept(building)
        obUnit.accept(uniti)
        obDoorplate.accept(doorPlate)
        
        var model = _obPositionModel.value
        model?.buildingNo = building
        model?.houseNum = uniti
        //        model?.doorplate = doorPlate
        _obPositionModel.accept(model)
    }
    
    
    func delete() -> Observable<Bool> {
        guard let id = LSLUser.current().scene?.ladderAssetHouseId else {
            return .empty()
        }
        
        return BusinessAPI.requestMapBool(.deleteAssetHouse(id: id)).do(onNext: { (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.deleteScene)
                LSLUser.current().scene = nil
            }
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        })
    }
    
    func save() -> Observable<Bool> {
        guard var param = self._obPositionModel.value else {
            return .empty()
        }
        
        param.id = self.id
        return BusinessAPI.requestMapBool(.editAssetHouse(parameter: param))
    }
    
}

extension PositionViewModel {
    struct Config {
        static let houseType = Array(0...9)
        static let towards = ["东", "南", "西", "北", "东南", "东西", "西南", "西北"]
        static let status = ["自住", "空置", "出租", "我是房客"]
    }
}
