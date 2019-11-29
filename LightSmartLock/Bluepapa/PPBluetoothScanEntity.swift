//
//  PPBluetoothScanEntity.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import CoreBluetooth


/// 封装的蓝牙对象
@objc public class PPScannedPeripheral: NSObject {
    
    public var peripheral  : CBPeripheral
    public var RSSI        : Int32
    public var isConnected : Bool
    public var dynamicPeripheralName: String?
    
    public init(withPeripheral aPeripheral: CBPeripheral, andRSSI anRSSI:Int32 = 0, andIsConnected aConnectionStatus: Bool, peripheralName: String?) {
        peripheral = aPeripheral
        RSSI = anRSSI
        isConnected = aConnectionStatus
        dynamicPeripheralName = peripheralName
    }
    
    public func name() -> String {
        let peripheralName = dynamicPeripheralName
        if dynamicPeripheralName == nil {
            return peripheral.name ?? "未知蓝牙"
        }else{
            return peripheralName!
        }
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let otherPeripheral = object as? PPScannedPeripheral {
            return peripheral == otherPeripheral.peripheral
        }
        return false
    }
}
