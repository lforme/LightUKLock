//
//  NetworkMetaDb.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import SQLite
import SwiftDate

final class NetworkMetaDb {
    
    let path: String
    var db: Connection?
    var table: Table
    
    let id = Expression<Int64>("id")
    let key = Expression<String>("key")
    let value = Expression<Data>("value")
    let accessTime = Expression<Date>("accessTime")
    let expirationTime = Expression<Date>("expirationTime")
    let accountId = Expression<String?>("accountId")
    
    private let lock = NSRecursiveLock()
    private let kDatabaseName = "cachedb.sqlite3"
    private let kTableName = "networkcache"
    
    init(path: String) {
        
        self.path = path.appending(kDatabaseName)
        self.table = Table(kTableName)
        initDb()
    }
    
    fileprivate func initDb() {
        do {
            self.db = try Connection(self.path)
            print("db path: \(self.path)")
        } catch {
            print(error.localizedDescription)
        }
        assert(self.db != nil)
        createTable()
    }
    
    fileprivate func createTable() {
        try! self.checkDb().run(self.table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(key, unique: true)
            t.column(value)
            t.column(accessTime)
            t.column(expirationTime)
            t.column(accountId)
        })
    }
    
    fileprivate func checkDb() -> Connection {
        guard let _db = self.db else {
            fatalError("db can not open")
        }
        return _db
    }
}

extension NetworkMetaDb {
    
    @discardableResult
    func save(_ value: Data, key: String) -> Bool {
        var result = false
        do {
            try db?.transaction {
                let filterTable = table.filter(self.key == key)
                if try checkDb().run(filterTable.update(
                    self.key <- key,
                    self.value <- value,
                    self.accessTime <- Date(),
                    self.accountId <- LSLUser.current().user?.accountID
                )) > 0 {
                    result = true
                } else {
                    let rowid = try checkDb().run(table.insert(
                        self.key <- key,
                        self.value <- value,
                        self.accessTime <- Date(),
                        self.expirationTime <- Date() + 7.days,
                        self.accountId <- LSLUser.current().user?.accountID
                    ))
                    
                    result = (rowid > Int64(0)) ? true : false
                }
            }
            return result
            
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    @discardableResult
    func value(forKey key: String) -> Data? {
        let query = self.table.select(self.table[*])
            .filter(self.key == key)
            .filter(self.accountId == LSLUser.current().user?.accountID)
            .limit(1)
        
        do {
            let rows = try checkDb().prepare(query)
            lock.lock()
            try db?.run(query.update(self.accessTime <- Date()))
            lock.unlock()
            
            if let row = Array(rows).last {
                let data = row[self.value]
                return data
            } else {
                return nil
            }
        } catch  {
            print(error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult
    func deleteExpiredData() -> Bool {
        let expired = self.table.select(self.table[*])
            .filter(self.accessTime > self.expirationTime)
        do {
            lock.lock()
            let result = try checkDb().run(expired.delete())
            lock.unlock()
            return result > 0
        } catch {
            print("delete expiredData failed: \(error)")
            return false
        }
    }
    
    @discardableResult
    func deleteValueBy(_ userId: String?) -> Bool {
        let value = self.table.filter(self.accountId == userId)
        do {
            lock.lock()
            let result = try self.checkDb().run(value.delete())
            lock.unlock()
            return result > 0
        } catch {
            print("delete expiredData failed: \(error)")
            return false
        }
    }
    
    @discardableResult
    func deleteAll() -> Bool {
        do {
            let result = try self.checkDb().run(self.table.delete())
            return result > 0
        } catch {
            print("delete expiredData failed: \(error)")
            return false
        }
    }
}
