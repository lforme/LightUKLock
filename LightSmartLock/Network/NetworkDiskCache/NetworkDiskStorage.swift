//
//  NetworkDiskStorage.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import SwiftDate

final class NetworkDiskStorage {
    
    var autoCleanTrash: Bool = true
    
    private let db: NetworkMetaDb
    
    init(autoCleanTrash: Bool? = true, path: String?) {
        
        self.autoCleanTrash = autoCleanTrash ?? true
        var documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        var p = documentsDirectory
        
        if let customPath = path {
            p += "/"
            p += customPath
        }
        
        if documentsDirectory.last! != "/" {
            documentsDirectory.append("/")
        }
        
        db = NetworkMetaDb(path: p)
        removeExpiredValues()
        
    }
    
    
    func save(value: Data, forKey key: String) {
        db.save(value, key: key)
    }
    
    @discardableResult
    func value(forKey key: String) -> Data? {
        return db.value(forKey: key)
    }
    
    @discardableResult
    func deleteAll() -> Bool {
        return db.deleteAll()
    }
    
    private func removeExpiredValues() {
        if !autoCleanTrash { return }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 60) {[weak self] in
            self?.db.deleteExpiredData()
            self?.removeExpiredValues()
        }
    }
}
