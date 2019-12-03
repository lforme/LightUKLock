//
//  SearchPlotViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxDataSources
import PKHUD
import Moya
import CoreLocation

final class SearchPlotViewModel {
    
    var sectionData: Observable<[SectionModel<String, GoudaMapItemModel>]> {
        return obSearchItems.map { (list) -> [SectionModel<String, GoudaMapItemModel>] in
            return [SectionModel(model: "小区搜索结果", items: list)]
        }
    }
    
    var refreshStaus: Observable<UKRefreshStatus> {
        return obRefreshStatus.asObservable()
    }
    
    var searchText = BehaviorRelay<String?>(value: nil)
    
    private let obSearchItems = BehaviorSubject<[GoudaMapItemModel]>(value: [])
    private var index = 1
    private var disposeBag = DisposeBag()
    private let locationServer = GeolocationService()
    private let service: RxMoyaProvider<AMapAPI> = RxMoyaProvider(endpointClosure: MoyaProvider.defaultEndpointMapping)
    private let obRefreshStatus = BehaviorRelay<UKRefreshStatus>(value: .none)
    
    private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0))
    
    init() {
        
        let shareText = searchText.share(replay: 1, scope: .forever)
        let shareLocation = locationServer.location.asObservable().share(replay: 1, scope: .forever)
        
        shareText.filter { $0?.isEmpty ?? false }.map { _ in Void() }.subscribe(onNext: {[weak self] (_) in
            self?.obSearchItems.onNext([])
            self?.obRefreshStatus.accept(.noMoreData)
        }).disposed(by: disposeBag)
    
        shareText.subscribe(onNext: {[weak self] (_) in
            self?.index = 1
        }).disposed(by: disposeBag)
        
        shareLocation.subscribe(onNext: {[weak self] (location) in
            self?.currentLocation = location
        }).disposed(by: disposeBag)
        
        let req = Observable.combineLatest(shareLocation, shareText.asObservable().filter { !($0?.isEmpty ?? true) }).flatMapLatest {[weak self] (location, keyWords) -> Observable<[GoudaMapItemModel]> in
            
            guard let this = self else {
                return .error(AppError.reason("出错啦"))
            }
            
            this.obRefreshStatus.accept(.endHeaderRefresh)
            
            return this.service.requestMapAny(.searchByKeyWords(keyWords!, currentLoction: (location.longitude, location.latitude), index: this.index)).map { (data) -> [GoudaMapItemModel] in
                
                let json = data as? [String: Any]
                let entitys = json?["pois"] as? [[String: Any]]
                guard let objects = [GoudaMapItemModel].deserialize(from: entitys) else {
                    return []
                }
                let e = objects.compactMap { $0 }
                return e
            }
        }
        
        req.bind(to: self.obSearchItems).disposed(by: disposeBag)
    }
    
    func loadMore() {
        index += 1
        
        service.requestMapAny(.searchByKeyWords(searchText.value ?? "", currentLoction: (currentLocation.longitude, currentLocation.latitude), index: index)).subscribe(onNext: {[weak self] (data) in
            
            guard let this = self else { return }
            
            let json = data as? [String: Any]
            let entitys = json?["pois"] as? [[String: Any]]
            
            let totalCount = json?["count"] as? String
            if let tc = totalCount {
                if this.index * 15 > Int(tc) ?? 0 {
                    this.obRefreshStatus.accept(.endFooterRefresh)
                    this.obRefreshStatus.accept(.noMoreData)
                } else {
                    this.obRefreshStatus.accept(.endFooterRefresh)
                }
            }
            
            if let objects = [GoudaMapItemModel].deserialize(from: entitys) {
                let e = objects.compactMap { $0 }
                if e.count == 0 {
                    this.obRefreshStatus.accept(.noMoreData)
                }
                var oldList = try! this.obSearchItems.value()
                oldList += e
                this.obSearchItems.onNext(oldList)
            } else {
                this.obRefreshStatus.accept(.noMoreData)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: disposeBag)
    }
}
