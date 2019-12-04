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
    
    let type: PositioEditingController.EditingType
    
    var defaultPositionModel: Observable<PositionModel?> {
        return Observable.merge(obPositionModel.asObservable(), _obPositionModel.asObservable())
    }
    
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
    
    init(type: PositioEditingController.EditingType) {
        
        self.type = type
        
        if type == .addNew {
            var newPos = PositionModel()
            newPos.sceneID = LSLUser.current().scene?.sceneID
            _obPositionModel.accept(newPos)
            obButtonType.accept(.save)
        } else {
            
            let shareReq = BusinessAPI.requestMapJSON(.getSceneAssets, classType: PositionModel.self, useCache: true).share(replay: 1, scope: .forever)
            
            Observable.combineLatest(obVillageName.asObservable(), obArea.asObservable(), obHouseType.asObservable(), obTowards.asObservable(), obDoorplate, obUnit.asObservable(), obCity.asObservable(), obRegion.asObservable()).subscribe(onNext: {[weak self] (_) in
                
                self?.obButtonType.accept(.save)
                
            }).disposed(by: disposeBag)
            
            self.obButtonType.accept(.delete)
            
            shareReq.bind(to: obPositionModel).disposed(by: disposeBag)
            
            shareReq.subscribe(onNext: {[weak self] (model) in
                self?._obPositionModel.accept(model)
            }).disposed(by: disposeBag)
        }
        
        obArea.subscribe(onNext: {[weak self] (area) in
            var param = self?._obPositionModel.value
            param?.area = area
            self?._obPositionModel.accept(param)
            
        }).disposed(by: disposeBag)
    }
    
    func setupPosition(_ village: String?, city: String?, region: String?) {
        obVillageName.accept(village)
        obCity.accept(city)
        obRegion.accept(region)
        var model = _obPositionModel.value
        model?.villageName = village
        model?.city = city
        model?.region = region
        _obPositionModel.accept(model)
    }
    
    func setupHouseType(_ type: String?) {
        obHouseType.accept(type)
        var model = _obPositionModel.value
        model?.houseType = type
        _obPositionModel.accept(model)
    }
    
    func setupTowards(_ towards: String?) {
        obTowards.accept(towards)
        var model = _obPositionModel.value
        model?.towards = towards
        _obPositionModel.accept(model)
    }
    
    func setupBuildingInfo(_ building: String?, uniti: String?, doorPlate: String?) {
        obBuilding.accept(building)
        obUnit.accept(uniti)
        obDoorplate.accept(doorPlate)
        
        var model = _obPositionModel.value
        model?.building = building
        model?.unit = uniti
        model?.doorplate = doorPlate
        _obPositionModel.accept(model)
    }
    
    
    func delete() -> Observable<Bool> {
        guard let id = LSLUser.current().scene?.sceneID else {
            return .empty()
        }
        return BusinessAPI.requestMapBool(.deleteSceneAssetsBySceneId(id))
    }
    
    func save() -> Observable<Bool> {
        guard let param = self._obPositionModel.value else {
            return .empty()
        }
        return BusinessAPI.requestMapJSON(.addOrUpdateSceneAsset(parameter: param), classType: PositionModel.self).map { _ in true }
    }
    
}

extension PositionViewModel {
    struct Config {
        static let houseType = Array(0...9)
        static let towards = ["东", "南", "西", "北", "东南", "东西", "西南", "西北"]
        static let status = ["自住", "空置", "出租", "我是房客"]
    }
}
