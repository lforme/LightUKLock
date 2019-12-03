//
//  GeolocationService.swift
//  IntelligentUOKO
//
//  Created by mugua on 2018/11/13.
//  Copyright © 2018 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class GeolocationService {
    
    //定位权限序列
    private (set) var authorized: Driver<Bool>
    
    //经纬度信息序列
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    //定位管理器
    private let locationManager = CLLocationManager()
    
    init() {
        
        //更新距离
        locationManager.distanceFilter = kCLDistanceFilterNone
        //设置定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //获取定位权限序列
        authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                case .authorizedWhenInUse:
                    return true
                default:
                    return false
                }
        }
        
        //获取经纬度信息序列
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
        
        //发送授权申请
        locationManager.requestWhenInUseAuthorization()
        //允许使用定位服务的话，开启定位服务更新
        locationManager.startUpdatingLocation()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}
