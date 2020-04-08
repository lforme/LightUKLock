//
//  BluetoothPapa.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth
import CryptoSwift


/// 监听蓝牙个状态
@objc public protocol UKBluetoothManagerDelegate {
    
    /// 已连接蓝牙
    ///
    /// - Parameter aName: 连接的蓝牙名称
    @objc optional func didConnectPeripheral(deviceName aName : String?)
    
    /// 蓝牙已断开
    @objc optional func didDisconnectPeripheral()
    
    /// 蓝牙准备就绪
    @objc optional func peripheralReady()
    
    /// 蓝牙未开启
    @objc optional func peripheralNotSupported()
}

public class BluetoothPapa: NSObject {
    
    public typealias PeripheralsCall = ([PPScannedPeripheral])->()
    public typealias BluetoothReceivedCall = (Data?)->()
    public typealias BluetoothStateCall = (CBManagerState)->()
    
    /// 获取操作实例
    public static let shareInstance = BluetoothPapa()
    
    fileprivate let lock = NSRecursiveLock()
    
    /// 蓝牙门锁通信加密密匙
    fileprivate var AESkey: String? {
        get {
            return LSLUser.current().lockInfo?.bluetoothPwd
        }
    }
    
    fileprivate var peripheralsResult: PeripheralsCall?
    fileprivate var receiveCall: BluetoothReceivedCall?
    fileprivate var checkBluetoothStata: BluetoothStateCall?
    
    /// UKBluetoothManagerDelegate
    public var delegate : UKBluetoothManagerDelegate?
    
    /// Private Property
    fileprivate let endMark = "#*#" // 35, 42, 35 十进制 23 2A 23
    fileprivate let MTU = 20
    private var bluetoothManager : CBCentralManager?
    private let centralQueue = DispatchQueue(label: "no.nordicsemi.swiftBluetooth", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    fileprivate let dfuServiceUUIDString  = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    fileprivate let ANCSServiceUUIDString = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    fileprivate var filterUUID: CBUUID?
    fileprivate var filterBluetoothNames: [String] = []
    fileprivate var peripherals: [PPScannedPeripheral] = []
    fileprivate var bluetoothPeripheral: CBPeripheral?
    fileprivate var connected = false
    fileprivate let UARTServiceUUID             : CBUUID
    fileprivate let UARTRXCharacteristicUUID    : CBUUID
    fileprivate let UARTTXCharacteristicUUID    : CBUUID
    fileprivate var uartRXCharacteristic        : CBCharacteristic?
    fileprivate var uartTXCharacteristic        : CBCharacteristic?
    fileprivate var bufferdData = Data()
    fileprivate let messageHeader = "FF0800" // FF下发08优客00不需要CRC
    
    override init() {
        UARTServiceUUID          = CBUUID(string: NORServiceIdentifiers.uartServiceUUIDString)
        UARTTXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartTXCharacteristicUUIDString)
        UARTRXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartRXCharacteristicUUIDString)
        super.init()
        commonInit()
    }
    
    fileprivate func commonInit() {
        bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
        if let blueName = LSLUser.current().lockInfo?.bluetoothName {
            filterBluetoothNames = [blueName, "UOKO", "UOKO_BLE"]
        } else {
            filterBluetoothNames = ["UOKO", "UOKO_BLE"]
        }
    }
    
    fileprivate func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        if filterUUID == nil {
            let dfuServiceUUID       = CBUUID(string: dfuServiceUUIDString)
            let ancsServiceUUID      = CBUUID(string: ANCSServiceUUIDString)
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [dfuServiceUUID, ancsServiceUUID])
        } else {
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [filterUUID!])
        }
        
        return retreivedPeripherals
    }
    
    fileprivate func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    fileprivate func encrypt(command: String) {
        
        guard let key = AESkey else {
            print("Not Found AES Key")
            return
        }
        
        do {
            guard let charArray = stringToBytes(command) else {
                print("转换失败")
                return
            }
            let encrypted = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(repeating: 1, count: 16)), padding: .pkcs7).encrypt(charArray)
            let end = Data(endMark.utf8)
            let uint8Array = [UInt8](end)
            let result = encrypted + uint8Array
            
            writeData(result)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate static func decrypted(data: Data?) -> [UInt8]? {
        
        guard let key = BluetoothPapa.shareInstance.AESkey, let data = data else {
            print("Not Found AES Key")
            return nil
        }
        do {
            let decrypted = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(repeating: 1, count: 16)), padding: .pkcs7).decrypt(data.bytes)
            
            return decrypted
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func writeData(_ encrypted: [UInt8]) {
        
        lock.lock()
        defer {
            lock.unlock()
        }
        
        guard self.bluetoothPeripheral != nil else {
            print("bluetoothPeripheral not found")
            return
        }
        
        guard self.uartRXCharacteristic != nil else {
            print("UART RX Characteristic not found")
            return
        }
        
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.uartRXCharacteristic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
            type = CBCharacteristicWriteType.withResponse
        }
        
        if encrypted.count > 20 {
            
            let splitEncrypted = encrypted.split20()
            splitEncrypted.forEach {[unowned self] en in
                let data = Data(en)
                self.bluetoothPeripheral!.writeValue(data, for: self.uartRXCharacteristic!, type: type)
            }
            
        } else {
            
            let data = Data(encrypted)
            self.bluetoothPeripheral!.writeValue(data, for: self.uartRXCharacteristic!, type: type)
        }
    }
    
    /// 开始扫描周围蓝牙设备
    ///
    /// - Parameter enable: true
    /// - Returns: resutl
    @discardableResult
    public func scanForPeripherals(_ enable: Bool) -> Bool {
        
        DispatchQueue.main.async {[weak self] in
            guard let this = self else {
                return
            }
            if enable == true {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                if this.filterUUID != nil {
                    this.bluetoothManager?.scanForPeripherals(withServices: [this.filterUUID!], options: options as? [String : AnyObject])
                } else {
                    this.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                }
            } else {
                this.bluetoothManager?.stopScan()
            }
        }
        return true
    }
    
    /// 设置过滤器，过滤扫描到的结果
    ///
    /// - Parameter txt: 需要扫描的蓝牙名称
    public func filterNames(_ txt: [String]) {
        txt.forEach{ assert($0.count > 0, "过滤名称为空") }
        
        filterBluetoothNames = txt
        peripherals.removeAll()
    }
    
    /// 扫描结果回掉
    ///
    /// - Parameter call: 返回扫描对象数组
    public func peripheralsScanResult(call: @escaping PeripheralsCall) {
        peripheralsResult = call
    }
    
    public func connect(peripheral: PPScannedPeripheral) {
        bluetoothPeripheral = peripheral.peripheral
        print(" : \(peripheral.name())...")
        bluetoothManager?.connect(peripheral.peripheral, options: nil)
    }
    
    /// 断开连接
    public func cancelPeripheralConnection() {
        guard let bluetoothPeripheral = self.bluetoothPeripheral else {
            print("Peripheral not set")
            return
        }
        
        if connected {
            print("Disconnecting...")
        } else {
            print("Cancelling connection...")
        }
        print("bluetoothPeripheral.cancelPeripheralConnection(peripheral)")
        bluetoothManager?.cancelPeripheralConnection(bluetoothPeripheral)
        connected = false
        // In case the previous connection attempt failed before establishing a connection
        if !connected {
            self.bluetoothPeripheral = nil
            delegate?.didDisconnectPeripheral?()
        }
    }
    
    /// 检查蓝牙是否链接
    ///
    /// - Returns: result
    public func isConnected() -> Bool {
        if self.bluetoothPeripheral?.state == .some(.connected) && self.connected {
            return true
        } else {
            return false
        }
    }
    
    /// 删除AESkey
    public func removeAESkey() {
        let array = Array(repeating: 0, count: 16).map { String($0) }.compactMap { $0 }
        let key = array.joined(separator:"")
        var lockInfo = LSLUser.current().lockInfo
        lockInfo?.bluetoothPwd = key
        LSLUser.current().lockInfo = lockInfo
    }
    
    /// 握手
    ///
    /// - Parameter call: 回调
    public func handshake(password: String? = "000000", userNumber: String? = "00", call: @escaping BluetoothReceivedCall) {
        assert(userNumber?.count == 2, "用户编号必须是2位")
        assert(password?.count == 6, "密码长度必须是6位")
        receiveCall = call
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let dateStr = dateFormatter.string(from: currentDate)
        
        let command = "\(messageHeader)060F\(dateStr)\(password!)\(userNumber!)"
        encrypt(command: command)
    }
    
    /// 设置加密 Key
    ///
    /// - Parameters:
    ///   - key: key
    ///   - call: 返回结果需要用 serialize 解析
    public func set(key: String, call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)160E\(key)"
        encrypt(command: command)
        
        var lockInfo = LSLUser.current().lockInfo
        lockInfo?.bluetoothPwd = key
        LSLUser.current().lockInfo = lockInfo
    }
    
    /// 改变蓝牙广播名
    ///
    /// - Parameter call: 回调
    public func changeBroadcastName(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let dateStr = dateFormatter.string(from: currentDate)
        
        let command = "\(messageHeader)030C\(dateStr)"
        encrypt(command: command)
    }
    
    
    /// 设置管理员密码
    ///
    /// - Parameters:
    ///   - password: 密码
    ///   - call: 回调
    public func setAdministrator(password: String, call: @escaping BluetoothReceivedCall) {
        
        assert(password.count == 6, "密码长度必须是6位")
        receiveCall = call
        let command = "\(messageHeader)030D\(password)"
        encrypt(command: command)
    }
    
    /// 重置用户密码
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号 0-99
    ///   - oldPassword: 旧密码
    ///   - newPassword: 新密码
    ///   - call: 回调
    public func resetUserPasswordBy(userNumber: String, oldPassword: String, newPassword: String, call: @escaping BluetoothReceivedCall) {
        assert(oldPassword.count == 6, "密码长度必须是6位")
        assert(newPassword.count == 6, "密码长度必须是6位")
        assert(userNumber.count < 100, "用户ID不合法")
        
        receiveCall = call
        let command = "\(messageHeader)070B\(oldPassword)\(userNumber)\(newPassword)"
        encrypt(command: command)
    }
    
    /// 开门
    ///
    /// - Parameter call: 返回结果 serialize 解析
    public func openDoor(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let dateStr = dateFormatter.string(from: currentDate)
        let command = "\(messageHeader)0601\(dateStr)"
        encrypt(command: command)
    }
    
    /// NB信号查询
    ///
    /// - Parameter call: 回调
    public func checkInfoOfNB(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0002"
        encrypt(command: command)
    }
    
    /// 设置音量大小
    ///
    /// - Parameters:
    ///   - volume: 1-4， 1 关闭声音提示， 4 最大声音
    ///   - call: 返回结果 serialize 解析
    public func setVoice(volume: Int, call: @escaping BluetoothReceivedCall) {
        assert(volume <= 4, "volume range 1 to 4, 1 is off, 4 is max")
        assert(volume >= 1, "volume range 1 to 4, 1 is off, 4 is max")
        receiveCall = call
        let command = "\(messageHeader)01040\(volume.description)"
        encrypt(command: command)
    }
    
    /// 重启设备
    public func reboot(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0005"
        encrypt(command: command)
    }
    
    /// 恢复出厂
    public func factoryReset(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0006"
        encrypt(command: command)
    }
    
    /// 查询电量
    ///
    /// - Parameter call: 返回结果 serialize 解析
    public func queryElectricQuantity(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0003"
        encrypt(command: command)
    }
    
    /// 查询版本
    ///
    /// - Parameter call: 返回结果 serialize 解析
    public func checkVersions(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0010"
        encrypt(command: command)
    }
    
    /// 添加用户
    ///
    /// - Parameters:
    ///   - password: 用户密码
    ///   - call: 返回结果 serialize 解析
    public func addUserBy(_ password: String, call: @escaping BluetoothReceivedCall) {
        assert(password.count == 6, "密码长度必须是6位")
        receiveCall = call
        let command = "\(messageHeader)030A\(password)"
        encrypt(command: command)
    }
    
    /// 删除用户
    ///
    /// - Parameters:
    ///   - password: 123456
    ///   - userNumber: 01
    ///   - call: 返回结果 serialize 解析
    public func deleteUserBy(_ password: String, userNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(password.count == 6, "密码长度必须是6位")
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)0309\(password)\(userNumber)"
        encrypt(command: command)
    }
    
    /// 获取音量大小
    ///
    /// - Parameters:
    ///   - call: 返回结果 serialize 解析
    public func getVoice(call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        let command = "\(messageHeader)0012"
        encrypt(command: command)
    }
    
    /// 添加指纹
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - call: 返回结果 serialize 解析
    public func addFinger(userNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)03080102\(userNumber)"
        encrypt(command: command)
    }
    
    /// 添加指纹确认操作
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - pwdNumber: 密码编号
    ///   - call: 返回结果 serialize 解析
    public func conformsFingerAction(userNumber: String, pwdNumber: String) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        assert(pwdNumber.count == 2, "用户编号长度必须是2位")
        let command = "\(messageHeader)030804\(userNumber)\(pwdNumber)"
        encrypt(command: command)
    }
    
    /// 删除指纹
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - pwdNumber: 密码编号
    public func deleteFinger(userNumber: String, pwdNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        assert(pwdNumber.count == 2, "用户编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)04080202\(userNumber)\(pwdNumber)"
        encrypt(command: command)
    }
    
    /// 设置为胁迫指纹
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - fingerNumber: 指纹编号
    ///   - call: 回调
    public func changeForceFinger(userNumber: String, fingerNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        assert(fingerNumber.count == 2, "指纹编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)030805\(userNumber)\(fingerNumber)"
        encrypt(command: command)
    }
    
    /// 检查蓝牙连接状态
    ///
    /// - Parameter call: 回调
    public func checkBluetoothState(call: @escaping BluetoothStateCall) {
        checkBluetoothStata = call
    }
    
    
    /// 添加门卡
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - call: 回调
    public func addCard(userNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)03080103\(userNumber)"
        encrypt(command: command)
    }
    
    /// 删除门卡
    ///
    /// - Parameters:
    ///   - userNumber: 用户编号
    ///   - call: 回调
    public func deleteCard(userNumber: String, keyNumber: String, call: @escaping BluetoothReceivedCall) {
        assert(userNumber.count == 2, "用户编号长度必须是2位")
        assert(keyNumber.count == 2, "密码编号长度必须是2位")
        receiveCall = call
        let command = "\(messageHeader)04080203\(userNumber)\(keyNumber)"
        encrypt(command: command)
    }
    
    
    /// 同步任务
    /// - Parameter task: 任务包
    /// - Parameter call: 回调
    public func synchronizeTask(task: String, call: @escaping BluetoothReceivedCall) {
        receiveCall = call
        encrypt(command: task)
    }
}

// MARK: - 解析回调数据
extension BluetoothPapa {
    
    /// 解析握手返回的内容
    ///
    /// - Parameter data: data
    /// - Returns: MAC & Administrator Password
    public static func serializeShake(_ data: Data?) -> (Mac: String, adminPassword: String)? {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        
        return (resultStr[10..<22], resultStr[22..<resultStr.count])
    }
    
    /// 解析设置key返回的内容
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeKey(_ data: Data?) -> (IMEI: String, IMSI: String)? {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        
        let resultStr = d.toHexString()
        
        let IMEI = resultStr[10..<26]
        let IMSI = resultStr[26..<42]
        return (IMEI, IMSI)
    }
    
    /// 解析开门回调
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeOpenDoor(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析设置密码回掉
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeAdminPassword(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析清除密码回掉
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeResetUserPassword(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析修改广播名
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeChangeBroadcastName(_ data: Data?) -> (Time: String, IMEIsuffix: String)? {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        
        return (resultStr[10..<16], resultStr[16..<resultStr.count])
        
    }
    
    /// 解析设置声音回掉
    ///
    /// - Parameter data: data
    /// - Returns: true
    public static func serializeVoice(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析电量
    ///
    /// - Parameter data: data
    /// - Returns: 电量
    public static func serializeElectric(_ data: Data?) -> CGFloat? {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        if let elect = Int(resultStr[10..<resultStr.count]) {
            return CGFloat(elect / 100)
        } else {
            return nil
        }
    }
    
    /// 解析NB信息
    ///
    /// - Parameter data: data
    /// - Returns: BN Info Dictionary
    public static func serializeNBInfo(_ data: Data?) -> [String: Any]? {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        var dit: [String: Any] = [:]
        dit.updateValue(resultStr[10..<26], forKey: "IMEI")
        dit.updateValue(resultStr[26..<42], forKey: "IMSI")
        dit.updateValue(resultStr[42..<44], forKey: "CSQ")
        dit.updateValue(resultStr[44..<48], forKey: "SP")
        dit.updateValue(resultStr[48..<58], forKey: "CellID")
        dit.updateValue(resultStr[58..<62], forKey: "SNR")
        dit.updateValue(resultStr[62..<66], forKey: "EARFCA")
        return dit
    }
    
    /// 解析重启的回调
    ///
    /// - Parameter data: data
    /// - Returns: 成功失败
    public static func serializeReboot(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析恢复出厂设置回调
    ///
    /// - Parameter data: data
    /// - Returns: 成功 失败
    public static func serializeFactory(_ data: Data?) -> Bool {
        
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[10..<12]
        
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析版本信息
    ///
    /// - Parameter data: data
    /// - Returns: 版本dic {"门锁版本": 01, "BN版本": 01, "蓝牙版本": 01}
    public static func serializeVersions(_ data: Data?) -> [String: Any]? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        let nbVersion = resultStr[10..<12]
        let bluetoothVersion = resultStr[12..<14]
        let fingerprintVersion = resultStr[14..<16]
        let lockVersion = resultStr[16..<20]
        
        return ["门锁版本": lockVersion, "BN版本": nbVersion, "蓝牙版本": bluetoothVersion, "指纹版本": fingerprintVersion]
    }
    
    /// 解析添加用户返回结果
    ///
    /// - Parameter data: data
    public static func serializeAddUser(_ data: Data?) -> [String: Any]?{
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        var isSuccess: Bool
        let s = resultStr[10..<12]
        let number = resultStr[12..<14]
        if s == "00" {
            isSuccess = true
        } else {
            isSuccess = false
        }
        
        return ["成功": isSuccess, "用户编号": number]
    }
    
    /// 解析删除用户返回结果
    ///
    /// - Parameter data: data
    public static func serializeDeleteUser(_ data: Data?) -> [String: Any]? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        var isSuccess: Bool
        let s = resultStr[10..<12]
        let number = resultStr[12..<14]
        if s == "00" {
            isSuccess = true
        } else {
            isSuccess = false
        }
        
        return ["成功": isSuccess, "用户编号": number]
    }
    
    /// 解析获取音量大小返回结果
    ///
    /// - Parameter data: data
    public static func serializeGetVolume(_ data: Data?) -> String? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        
        let volume = resultStr[10..<12]
        return volume
    }
    
    /// 解析添加指纹
    ///
    /// - Parameter data: data
    /// - Returns: 添加到第几部
    public static func serializeAddFinger(_ data: Data?) -> [String: Any]? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        if resultStr.count < 20 {
            return nil
        }
        let step = resultStr[14..<16]
        let pwdNumber = resultStr[18..<20]
        return ["步骤": step, "密码编号": pwdNumber]
    }
    
    /// 解析删除指纹
    ///
    /// - Parameter data: data
    /// - Returns: 删除指纹结果
    public static func serializeDeleteFinger(_ data: Data?) -> Bool {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return false
        }
        let resultStr = d.toHexString()
        let isSuccess = resultStr[12..<14]
        if isSuccess == "00" {
            return true
        } else {
            return false
        }
    }
    
    /// 解析胁迫指纹开门
    ///
    /// - Parameter data: data
    /// - Returns: 字典 ["用户编号": userNumber, "指纹编号": fingerNumber]
    public static func serializeChangeForceFinger(_ data: Data?) -> [String: Any]? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        if resultStr.count >= 16 {
            let userNumber = resultStr[12..<14]
            let fingerNumber = resultStr[14..<16]
            return ["用户编号": userNumber, "指纹编号": fingerNumber]
        } else  {
            return nil
        }
    }
    
    /// 解析添加门卡
    ///
    /// - Parameter data: 数据
    /// - Returns: 字典["结果": Bool, "用户编号": String, "密码编号": String]
    public static func serializeAddCard(_ data: Data?) -> [String: Any]? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        if resultStr.count < 20 {
            return nil
        }
        var dict: [String: Any] = [:]
        
        let result = resultStr[14..<16]
        let userNumber = resultStr[16..<18]
        let pwdNumber = resultStr[18..<20]
        
        if result == "00" {
            dict.updateValue(true, forKey: "结果")
        } else {
            dict.updateValue(false, forKey: "结果")
        }
        dict.updateValue(userNumber, forKey: "用户编号")
        dict.updateValue(pwdNumber, forKey: "密码编号")
        return dict
    }
    
    /// 解析同步任务返回结果
    /// - Parameter data: 门锁返回结果
    public static func serializeSynchronizeTask(_ data: Data?) -> String? {
        let decryptData = BluetoothPapa.decrypted(data: data)
        guard let d = decryptData else {
            print("decrypted failure")
            return nil
        }
        let resultStr = d.toHexString()
        
        return resultStr
    }
}



// MARK: - 不要重写
extension BluetoothPapa: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        DispatchQueue.main.async {[weak self] in
            self?.checkBluetoothStata?(central.state)
        }
        
        guard central.state == .poweredOff else {
            return
        }
        
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [PPScannedPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let connected = connectedPeripheral.state == .connected
            let scannedPeripheral = PPScannedPeripheral(withPeripheral: connectedPeripheral, andIsConnected: connected, peripheralName: nil)
            newScannedPeripherals.append(scannedPeripheral)
        }
        peripherals = newScannedPeripherals
        let success = self.scanForPeripherals(true)
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[Callback] Central Manager did connect peripheral")
        if let name = peripheral.name {
            print("Connected to: \(name)")
        } else {
            print("Connected to device")
        }
        
        connected = true
        bluetoothPeripheral = peripheral
        bluetoothPeripheral?.delegate = self
        delegate?.didConnectPeripheral?(deviceName: peripheral.name)
        print("Discovering services...")
        print("peripheral.discoverServices([\(UARTServiceUUID.uuidString)])")
        peripheral.discoverServices([UARTServiceUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        guard error == nil else {
            print("[Callback] Central Manager did disconnect peripheral")
            print(error?.localizedDescription ?? "")
            return
        }
        print("[Callback] Central Manager did disconnect peripheral successfully")
        print("Disconnected")
        cancelPeripheralConnection()
        connected = false
        delegate?.didDisconnectPeripheral?()
        bluetoothPeripheral?.delegate = nil
        bluetoothPeripheral = nil
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            print("[Callback] Central Manager did fail to connect to peripheral")
            print(error?.localizedDescription ?? "")
            return
        }
        print("[Callback] Central Manager did fail to connect to peripheral without errors")
        print("Failed to connect")
        
        connected = false
        delegate?.didDisconnectPeripheral?()
        bluetoothPeripheral?.delegate = nil
        bluetoothPeripheral = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async(execute: {
            let dynamicPeripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            var sensor = PPScannedPeripheral(withPeripheral: peripheral, andRSSI: RSSI.int32Value, andIsConnected: false, peripheralName: dynamicPeripheralName)
            if ((self.peripherals.contains(sensor)) == false) {
                
                if self.filterBluetoothNames.count > 0 {
                    
                    self.filterBluetoothNames.forEach({ (aName) in
                        if sensor.name().contains(aName) {
                            self.peripherals.append(sensor)
                        }
                    })
                    
                } else {
                    self.peripherals.append(sensor)
                }
                if let name = peripheral.name, !self.connected {
                    print("scan bluethooth name: \(name)")
                }
                self.peripheralsResult?(self.peripherals)
            } else {
                sensor = self.peripherals[self.peripherals.firstIndex(of: sensor)!]
                sensor.RSSI = RSSI.int32Value
            }
        })
    }
}

// MARK: - 不要重写
extension BluetoothPapa: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for aService: CBService in peripheral.services! {
            if aService.uuid.isEqual(UARTServiceUUID) {
                bluetoothPeripheral!.discoverCharacteristics(nil, for: aService)
                return
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Characteristics discovery failed")
            print(error?.localizedDescription ?? "")
            return
        }
        print("Characteristics discovered")
        
        if service.uuid.isEqual(UARTServiceUUID) {
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                if aCharacteristic.uuid.isEqual(UARTTXCharacteristicUUID) {
                    print("TX Characteristic found")
                    uartTXCharacteristic = aCharacteristic
                } else if aCharacteristic.uuid.isEqual(UARTRXCharacteristicUUID) {
                    print("RX Characteristic found")
                    uartRXCharacteristic = aCharacteristic
                }
            }
            //Enable notifications on TX Characteristic
            if (uartTXCharacteristic != nil && uartRXCharacteristic != nil) {
                print("Enabling notifications for \(uartTXCharacteristic!.uuid.uuidString)")
                print("peripheral.setNotifyValue(true, for: \(uartTXCharacteristic!.uuid.uuidString))")
                bluetoothPeripheral!.setNotifyValue(true, for: uartTXCharacteristic!)
            } else {
                print("UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
                delegate?.peripheralNotSupported?()
                cancelPeripheralConnection()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Updating characteristic has failed")
            print(error?.localizedDescription ?? "")
            self.receiveCall?(nil)
            return
        }
        
        // try to print a friendly string of received bytes if they can be parsed as UTF8
        guard let bytesReceived = characteristic.value else {
            print("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            print("Empty packet received")
            self.receiveCall?(nil)
            return
        }
        // 切换到主线程
        DispatchQueue.main.async {
            
            bytesReceived.withUnsafeBytes {(unsafePointer) -> Void in
                let utf8Bytes = unsafePointer.bindMemory(to: CChar.self)
                var len = bytesReceived.count
                if utf8Bytes[len - 1] == 0 {
                    len -= 1 // if the string is null terminated, don't pass null terminator into NSMutableString constructor
                }
                let array = [UInt8](bytesReceived)
                let endElements = Array(array[(array.count-3)..<array.count])
                if [35, 42, 35] == Array(endElements) {
                    // 结束
                    let tobeDecrypt = Array(array[0..<(array.count - 3)])
                    self.bufferdData += Data(tobeDecrypt)
                    self.receiveCall?(self.bufferdData)
                    self.bufferdData = Data()
                } else {
                    // 缓存
                    self.bufferdData += array
                }
                print("Notification received from: \(characteristic.uuid.uuidString), with value: 0x\(bytesReceived)")
                print(array)
                
            }
            
        }
    }
}

fileprivate extension String {
    
    var pairs: [String] {
        var result: [String] = []
        let characters = Array(self)
        stride(from: 0, to: count, by: 2).forEach {
            result.append(String(characters[$0..<min($0+2, count)]))
        }
        return result
    }
    
    mutating func insert(separator: String, every n: Int) {
        self = inserting(separator: separator, every: n)
    }
    
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self)
        stride(from: 0, to: count, by: n).forEach {
            result += String(characters[$0..<min($0+n, count)])
            if $0+n < count {
                result += separator
            }
        }
        return result
    }
}

fileprivate extension Array {
    
    func split20() -> [[Element]] {
        return chunked(into: 20)
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
