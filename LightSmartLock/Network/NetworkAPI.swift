//
//  NetworkAPI.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Moya

private let authEndpointClosure = { (target: AuthenticationInterface) -> Endpoint in
    let url = (target.baseURL.absoluteString + target.path).removingPercentEncoding!
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
}

private let BusinessEndpointClosure = { (target: BusinessInterface) -> Endpoint in
    let url = (target.baseURL.absoluteString + target.path).removingPercentEncoding!
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
}

let AuthAPI: RxMoyaProvider = RxMoyaProvider(endpointClosure: authEndpointClosure)
let BusinessAPI: RxMoyaProvider = RxMoyaProvider(endpointClosure: BusinessEndpointClosure)
