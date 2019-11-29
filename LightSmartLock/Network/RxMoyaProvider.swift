//
//  RxMoyaProvider.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Moya
import RxCocoa
import RxSwift
import Alamofire
import HandyJSON
import PKHUD

fileprivate let lock = DispatchSemaphore(value: 1)

final class RxMoyaProvider<Target>: MoyaProvider<Target> where Target: TargetType {
    
    fileprivate let stubScheduler: SchedulerType?
    fileprivate var authenticationBlock = { (_ done: () -> Void) -> Void in
        print("Execute refresh and after retry! !!!")
        lock.wait()
        do {
            done()
            lock.signal()
            print("Refresh token Done !!!!")
        }
    }
    
    fileprivate let diskCache = NetworkDiskStorage(autoCleanTrash: true, path: "network")
    
    init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
         plugins: [PluginType] = [LoadingPlugin(), NetworkLoggerPlugin(verbose: true, responseDataFormatter: { (data) -> (Data) in
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
        
    })],
         stubScheduler: SchedulerType? = nil,
         trackInflights: Bool = false) {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        self.stubScheduler = stubScheduler
        
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: nil, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
}


private extension RxMoyaProvider {
    
    private func useCacheWhenErrorOccurred(_ token: Target) -> Observable<Response> {
        
        if let interface = token as? BusinessInterface {
            var key = interface.path + interface.method.rawValue
            if let param = interface.parameters {
                for (k, v) in param {
                    key += k
                    if let vStr = v as? String {
                        key += "=\(vStr)&"
                    }
                    
                    if let vStr = v as? Int {
                        key += "=\(vStr)&"
                    }
                    
                    if let vStr = v as? Bool {
                        key += "=\(vStr)&"
                    }
                }
            }
            // 读取缓存
            print("读取 Key: \(key)")
            guard let data = diskCache.value(forKey: "key") else {
                return self._request(token)
            }
            let cache = Response(statusCode: 200, data: data, request: nil, response: nil)
            return self._request(token).catchErrorJustReturn(cache)
        }
        
        return self._request(token)
    }
    
    
    private func _request(_ token: Target, tryAfterAuth: Int = 1) -> Observable<Response> {
        
        return self.rx.request(token)
            .asObservable()
            .throttle(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest {[unowned self] (res) -> Observable<Response> in
                
                if res.statusCode == 401 {
                    return Observable.create({ (observer) -> Disposable in
                        self.authenticationBlock {
                            // 刷新 Token
                            
                            let refreshTokenRequest = AuthAPI.requestMapAny(.refreshUserToken)
                                .map { (any) -> AccessTokenModel? in
                                    let json = any as? [String: Any]
                                    return AccessTokenModel.deserialize(from: json)
                            }
                            
                            refreshTokenRequest.do(onError: { (error) in
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    HUD.flash(.label("令牌过期,请重新登录"), delay: 2)
                                    LSLUser.current().logout()
                                })
                                
                            }).subscribe(onNext: { (t) in
                                
                                // 保存最新token
                                LSLUser.current().refreshToken = t
                                LSLUser.current().token = t
                                
                                self._request(token).subscribe({ (event) in
                                    observer.on(event)
                                }).disposed(by: self.rx.disposeBag)
                                
                            }).disposed(by: self.rx.disposeBag)
                        }
                        return Disposables.create()
                    })
                } else if res.statusCode == 429 {
                    return Observable.error(AppError.reason("请求过于频繁"))
                } else if res.statusCode == 500 {
                    if let json = try? res.mapJSON(), let dict = json as? [String: Any] {
                        let eMsg = dict["Msg"] as? String
                        return Observable.error(AppError.reason(eMsg ?? "服务器出错啦"))
                    } else {
                        return Observable.error(AppError.reason("服务器出错啦"))
                    }
                } else {
                    
                    // 写入缓存
                    if let interface = token as? BusinessInterface {
                        var key = interface.path + interface.method.rawValue
                        if let param = interface.parameters {
                            for (k, v) in param {
                                key += k
                                if let vStr = v as? String {
                                    key += "=\(vStr)&"
                                }
                                
                                if let vStr = v as? Int {
                                    key += "=\(vStr)&"
                                }
                                
                                if let vStr = v as? Bool {
                                    key += "=\(vStr)&"
                                }
                            }
                        }
                        print("写入 Key: \(key)")
                        self.diskCache.save(value: res.data, forKey: "key")
                    }
                    
                    return Observable.just(res)
                }
        }.observeOn(MainScheduler.instance)
            .retry(tryAfterAuth)
    }
    
}


extension RxMoyaProvider {
    
    func requestMapBool(_ token: Target) -> Observable<Bool> {
        
        return _request(token).flatMap({ (response) -> Observable<Bool> in
            guard let json = try? response.mapJSON(failsOnEmptyData: true), let dict = json as? [String: Any] else {
                return .error(AppError.reason(response.description))
            }
            if let code = dict["Code"] as? Int, code == 1 {
                return .just(true)
            } else {
                return .just(false)
            }
        })
    }
    
    func requestMapAny(_ token: Target, useCache: Bool = false) -> Observable<Any> {
        
        if useCache {
            return useCacheWhenErrorOccurred(token).flatMap({ (response) -> Observable<Any> in
                guard let json = try? response.mapJSON(failsOnEmptyData: true) else {
                    return .error(AppError.reason(response.description))
                }
                return Observable.just(json)
            })
        }
        
        return _request(token).flatMap({ (response) -> Observable<Any> in
            guard let json = try? response.mapJSON(failsOnEmptyData: true) else {
                return .error(AppError.reason(response.description))
            }
            return Observable.just(json)
        })
    }
    
    
    func requestMapJSON<E: HandyJSON>(_ token: Target, classType: E.Type, useCache: Bool = false) -> Observable<E> {
        
        if useCache {
            return useCacheWhenErrorOccurred(token).flatMap({ (response) -> Observable<E> in
                
                guard let json = try? response.mapJSON() else {
                    return .error(AppError.reason("服务器出错啦"))
                }
                
                guard let dic = json as? [String: Any], let status = dic["Code"] as? Int else {
                    return .error(AppError.reason("服务器出错啦"))
                }
                
                if status == 1  {
                    let value = dic["Data"] as? [String: Any]
                    if let object = E.deserialize(from: value) {
                        return Observable.just(object)
                    } else {
                        return Observable.empty()
                    }
                } else {
                    let e = dic["Msg"] as? String
                    return Observable.error(AppError.reason(e ?? ""))
                }
            })
        }
        
        return _request(token).flatMap({ (response) -> Observable<E> in
            
            guard let json = try? response.mapJSON() else {
                return .error(AppError.reason("服务器出错啦"))
            }
            
            guard let dic = json as? [String: Any], let status = dic["Code"] as? Int else {
                return .error(AppError.reason("服务器出错啦"))
            }
            
            if status == 1 {
                let value = dic["Data"] as? [String: Any]
                if let object = E.deserialize(from: value) {
                    return Observable.just(object)
                } else {
                    return Observable.empty()
                }
            } else {
                let e = dic["Msg"] as? String
                return Observable.error(AppError.reason(e ?? ""))
            }
        })
    }
    
    
    func requestMapJSONArray<E: HandyJSON>(_ token: Target, classType: E.Type, useCache: Bool = false) -> Observable<[E?]> {
        
        if useCache {
            return useCacheWhenErrorOccurred(token).flatMap({ (response) -> Observable<[E?]> in
                
                guard let json = try? response.mapJSON() else {
                    return .error(AppError.reason("服务器出错啦"))
                }
                
                guard let dic = json as? [String: Any], let code = dic["Code"] as? Int else {
                    return .error(AppError.reason("服务器出错啦"))
                }
                
                if code == 1 {
                    
                    let value = dic["Data"] as? [[String: Any]]
                    
                    if let objects = [E].deserialize(from: value) {
                        
                        return Observable.just(objects)
                    } else {
                        return .error(AppError.reason("服务器出错啦"))
                    }
                } else {
                    let e = dic["Msg"] as? String
                    return Observable.error(AppError.reason(e ?? ""))
                }
            })
        }
        
        return _request(token).flatMap({ (response) -> Observable<[E?]> in
            
            guard let json = try? response.mapJSON() else {
                return .error(AppError.reason("服务器出错啦"))
            }
            
            guard let dic = json as? [String: Any], let code = dic["Code"] as? Int else {
                return .error(AppError.reason("服务器出错啦"))
            }
            
            if code == 1 {
                
                let value = dic["Data"] as? [[String: Any]]
                
                if let objects = [E].deserialize(from: value) {
                    
                    return Observable.just(objects)
                } else {
                    return .error(AppError.reason("服务器出错啦"))
                }
            } else {
                let e = dic["Msg"] as? String
                return Observable.error(AppError.reason(e ?? ""))
            }
        })
    }
}
