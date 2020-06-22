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
    
    fileprivate let dateFormatter: DateFormatter
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
    
    fileprivate let diskCache = NetworkDiskStorage(autoCleanTrash: true, path: "lightSmartLock.network")
    
    init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
         plugins: [PluginType] = [LoadingPlugin()],
         stubScheduler: SchedulerType? = nil,
         trackInflights: Bool = false) {
        
        let configuration = URLSessionConfiguration.af.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        let manager = Session(configuration: configuration, startRequestsImmediately: false)
        
        self.stubScheduler = stubScheduler
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        var mutablePlugins = plugins
        
        mutablePlugins += [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: RxMoyaProvider<Target>.JSONResponseDataFormatter),
                                                                    logOptions: .verbose))]
        
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: nil, session: manager, plugins: mutablePlugins, trackInflights: trackInflights)
        
    }
    
    private static func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
}


private extension RxMoyaProvider {
    
    private func useCacheWhenErrorOccurred(_ token: Target) -> Observable<Response> {
        
        if let interface = token as? BusinessInterface {
            var key = interface.path + interface.method.rawValue
            if let param = interface.parameters?.sorted(by: { (a, b) -> Bool in
                return a.key < b.key
            }).description {
                key += param
            }
            // 读取缓存
            let md5 = key.md5()
            guard let data = diskCache.value(forKey: md5) else {
                return self._request(token)
            }
            print("⏰=> 缓存读取时间: [\(self.dateFormatter.string(from: Date()))]\n\("🧤=> 读取成功 ✌️✌️✌️")\n\("💡=> 缓存Key: \(md5)")")
            
            let cache = Response(statusCode: 200, data: data, request: nil, response: nil)
            return self._request(token).catchErrorJustReturn(cache)
        }
        
        return self._request(token)
    }
    
    
    private func _request(_ token: Target, tryAfterAuth: Int = 1) -> Observable<Response> {
        
        return self.rx.request(token)
            .asObservable()
            .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest {[unowned self] (res) -> Observable<Response> in
                
                if res.statusCode == 401 {
                    return Observable.create({ (observer) -> Disposable in
                        self.authenticationBlock {
                            // 刷新 Token
                            
                            guard let oldToken = LSLUser.current().token?.accessToken else {
                                return
                            }
                            
                            let refreshTokenRequest = AuthAPI.requestMapJSON(.refreshToken(token: oldToken), classType: AccessTokenModel.self)
                            
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
                    return Observable.error(AppError.reason("服务器出错了"))
                } else if res.statusCode == 200 {
                    
                    // 写入缓存
                    if let interface = token as? BusinessInterface {
                        var key = interface.path + interface.method.rawValue
                        if let param = interface.parameters?.sorted(by: { (a, b) -> Bool in
                            return a.key < b.key
                        }).description {
                            key += param
                        }
                        
                        let md5 = key.md5()
                        self.diskCache.save(value: res.data, forKey: md5)
                        print("⏰=> 本地缓存写入时间: [\(self.dateFormatter.string(from: Date()))]\n\("🧤=> 本地缓存写入成功 🐸🐸🐸")\n\("💡=> 缓存Key: \(md5)")")
                    }
                    return Observable.just(res)
                } else {
                    return Observable.just(res)
                }
        }.observeOn(MainScheduler.instance)
            .retry(tryAfterAuth)
    }
}


extension RxMoyaProvider {
    
    func requestMapBool(_ token: Target) -> Observable<Bool> {
        
        return _request(token).flatMapLatest({ (response) -> Observable<Bool> in
            guard let json = try? response.mapJSON(failsOnEmptyData: true), let dict = json as? [String: Any] else {
                return .error(AppError.reason(response.description))
            }
            if let code = dict["status"] as? Int, code == 200 {
                return .just(true)
            } else {
                let msg = dict["message"] as? String
                return .error(AppError.reason(msg ?? ""))
            }
        })
    }
    
    func requestMapAny(_ token: Target, useCache: Bool = false) -> Observable<Any> {
        
        if useCache {
            return useCacheWhenErrorOccurred(token).flatMapLatest({ (response) -> Observable<Any> in
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
            return useCacheWhenErrorOccurred(token).flatMapLatest({ (response) -> Observable<E> in
                
                guard let json = try? response.mapJSON() else {
                    return .error(AppError.reason("服务器出错了"))
                }
                
                guard let dic = json as? [String: Any], let status = dic["status"] as? Int else {
                    return .error(AppError.reason("服务器出错了"))
                }
                
                if status == 200 {
                    let value = dic["data"] as? [String: Any]
                    if let object = E.deserialize(from: value) {
                        return Observable.just(object)
                    } else {
                        return Observable.empty()
                    }
                } else {
                    let e = dic["message"] as? String
                    return Observable.error(AppError.reason(e ?? ""))
                }
            })
        }
        
        return _request(token).flatMap({ (response) -> Observable<E> in
            
            guard let json = try? response.mapJSON() else {
                return .error(AppError.reason("服务器出错了"))
            }
            
            guard let dic = json as? [String: Any], let status = dic["status"] as? Int else {
                return .error(AppError.reason("服务器出错了"))
            }
            
            if status == 200 {
                let value = dic["data"] as? [String: Any]
                if let object = E.deserialize(from: value) {
                    return Observable.just(object)
                } else {
                    return Observable.empty()
                }
            } else {
                let e = dic["message"] as? String
                return Observable.error(AppError.reason(e ?? ""))
            }
        })
    }
    
    
    func requestMapJSONArray<E: HandyJSON>(_ token: Target, classType: E.Type, useCache: Bool = false, isPaginating: Bool? = false) -> Observable<[E?]> {
        
        if useCache {
            return useCacheWhenErrorOccurred(token).flatMapLatest({ (response) -> Observable<[E?]> in
                
                guard let json = try? response.mapJSON() else {
                    return .error(AppError.reason("服务器出错了"))
                }
                
                guard let dic = json as? [String: Any], let code = dic["status"] as? Int else {
                    return .error(AppError.reason("服务器出错了"))
                }
                
                if code == 200 {
                    if isPaginating ?? false {
                        let res = dic["data"] as? [String: Any]
                        let value = res?["rows"] as? [[String: Any]]
                        if let objects = [E].deserialize(from: value) {
                            return Observable.just(objects)
                        } else {
                            return .error(AppError.reason("服务器出错了"))
                        }
                    } else {
                        let value = dic["data"] as? [[String: Any]]
                        if let objects = [E].deserialize(from: value) {
                            return Observable.just(objects)
                        } else {
                            return .error(AppError.reason("服务器出错了"))
                        }
                    }
                } else {
                    let e = dic["message"] as? String
                    return Observable.error(AppError.reason(e ?? ""))
                }
            })
        }
        
        return _request(token).flatMap({ (response) -> Observable<[E?]> in
            
            guard let json = try? response.mapJSON() else {
                return .error(AppError.reason("服务器出错了"))
            }
            
            guard let dic = json as? [String: Any], let code = dic["status"] as? Int else {
                return .error(AppError.reason("服务器出错了"))
            }
            
            if code == 200 {
                if isPaginating ?? false {
                    let res = dic["data"] as? [String: Any]
                    let value = res?["rows"] as? [[String: Any]]
                    if let objects = [E].deserialize(from: value) {
                        return Observable.just(objects)
                    } else {
                        return .error(AppError.reason("服务器出错了"))
                    }
                } else {
                    let value = dic["data"] as? [[String: Any]]
                    if let objects = [E].deserialize(from: value) {
                        return Observable.just(objects)
                    } else {
                        return .error(AppError.reason("服务器出错了"))
                    }
                }
            } else {
                let e = dic["message"] as? String
                return Observable.error(AppError.reason(e ?? ""))
            }
        })
    }
}
