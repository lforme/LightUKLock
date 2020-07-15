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
            return "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "v1.0") d"
        case .production:
            return "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "v1.0") p"
        }
    }
    
    var host: String {
        switch self {
        case .dev:
            return "http://test.uokohome.com:19999"
        case .production:
            return "https://ladder.uokohome.com:19999"
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
