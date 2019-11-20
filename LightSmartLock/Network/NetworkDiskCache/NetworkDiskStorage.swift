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
        if documentsDirectory.last! != "/" {
            documentsDirectory.append("/")
        }
        let _path = path ?? documentsDirectory
        db = NetworkMetaDb(path: _path)
        removeExpiredValues()
    }
    
    func save(value: Data, forKey key: String) {
        db.save(value, key: key)
    }
    
    @discardableResult
    func value(forKey key: String) -> Data? {
        return db.value(forKey: key)
    }
    
    private func removeExpiredValues() {
        if !autoCleanTrash { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            DispatchQueue.global(qos: .background).async {[weak self] in
                self?.db.deleteExpiredData()
            }
            self.removeExpiredValues()
        }
    }
}
