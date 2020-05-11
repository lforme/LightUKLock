//
//  NetworkInterface.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON

// 高德地图 Web API
enum AMapAPI {
    case searchByKeyWords(_ keyWords: String, currentLoction:(Double, Double), index: Int) // 搜索周边
}


enum AuthenticationInterface {
    
    case verificationCode(phone: String) // 获取短信验证码
    case registeriOS(phone: String, password: String, msmCode: String) // 验证短信验证码并登录
    case forgetPasswordiOS(phone: String, password: String, msmCode: String) // 验证短信验证码并修改密码
    case login(userName: String, password: String) // 用户面密码登录
    case verificationCodeValid(code: String, phone: String) // 验证短信接口
    case refreshToken(token: String) // 刷新token
    case logout(token: String) // 退出登录
}


enum BusinessInterface {
   
    // 新添加的
    case uploadImage(UIImage, description: String) // 图片上传
    case user // 获取当前用户信息
    case getHouses // 获取资产列表
    case deleteAssetHouse(id: String) // 删除资产
    case getAssetHouseDetail(id: String) // 获取资产详情
    case editAssetHouse(parameter: PositionModel) // 绑定,编辑资产
    case addLock(parameter: LockModel) // 添加门锁
    case getLockInfo(id: String) // 获取设备信息
    case getHomeInfo(id: String) // 获取首页信息
    case forceDeleteLock(id: String) // 强制删除门锁
    case getUserList(lockId: String, pageIndex: Int, pageSize: Int?) // 用户列表
    case uploadOpenDoorRecord(lockId: String, time: String, type: Int) // 上传解锁记录
    case addUserByBluethooth(parameter: UserMemberListModel) // 蓝牙添加用户
    case getCustomerSysRoleTips // 获取系统内置标签
    case editUser(parameter: HandyJSON) //编辑用户
    case deleteUserBy(id: String) // 删除用户
    case getAllOpenWay(lockId: String) // 获取聚合门锁信息接口
    case addCard(lockId: String, keyNum: String, name: String) // 添加门卡
    case editCardOrFingerName(id: String, name: String) // 修改门卡, 指纹名称
    case deleteCard(id: String, operationType: Int) // 删除门卡 1本地（蓝牙） 2远程（NB）
    case addFinger(lockId: String, keyNum: String, name: String, phone: String?) // 添加指纹
    case deleteFinger(id: String, operationType: Int) // 删除指纹
    case setAlarmFingerprint(id: String, phone: String, operationType: Int) // 设置胁迫指纹
    case addAndModifyDigitalPassword(lockId: String, password: String, operationType: Int) // 修改数字密码
    case getTempPasswordList(lockId: String, pageIndex: Int, pageSize: Int?) // 获取临时密码列表
    case getTempPasswordLog(id: String) // 获取临时密码记录
    case undoTempPassword(id: String) // 撤销临时密码
    case addTempPassword(lockId: String, parameter: TempPasswordShareParameter) // 添加临时密码
    case getUnlockRecords(lockId: String, type: Int, pageIndex: Int, pageSize: Int?) // 获取开门记录 1今天 2昨天 3全部
    case reportAsset(assetId: String, year: String) // 获取报表列表
    case baseTurnoverInfoList(assetId: String, year: String) // 获取流水列表
    case tenantContractInfoAssetContract(assetId: String, year: String) // 资产合同列表
    case reportReportItems(assetId: String, costId: String) // 获取报名费用类型明细
    case baseTurnoverInfo(assetId: String, contractId: String, payTime: String, itemList: [AddFlowParameter])
}
