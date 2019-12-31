//
//  NetworkingEnvironment.swift
//  HannibalButler
//
//  Created by mugua on 2019/7/1.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation

enum NetworkingEnvironment: Int, CustomStringConvertible, CaseIterable {
    case production = 0
    case dev
    
    var description: String {
        switch self {
        case .dev:
            return "开发"
        case .production:
            return "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "v1.0")"
        }
    }
    
    var host: String {
        switch self {
        case .dev:
            return "http://appapi.jinriwulian.com/"
        case .production:
            return "http://appapi.jinriwulian.com/"
        }
    }
    
}

class ServerHost {
    
    fileprivate struct Key {
        fileprivate static let current = "com.why.currentEnviroment"
    }
    
    static let shared = ServerHost()
    
    var environment: NetworkingEnvironment {
        get {
            guard let type = LocalArchiver.load(key: Key.current) as? Int else {
                
                return .production
            }
            return NetworkingEnvironment(rawValue: type) ?? .production
        }
        
        set {
            switchServerHost(environment: newValue)
        }
    }
    
    private init() {}
    
    private func switchServerHost(environment: NetworkingEnvironment) {
        LocalArchiver.save(key: Key.current, value: environment.rawValue)
    }
}
