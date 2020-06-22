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
import CoreLocation

// 高德地图 Web API
enum AMapAPI {
    case searchByKeyWords(_ keyWords: String, currentLoction:(Double, Double), index: Int) // 搜索周边
    case geoCode(location: CLLocationCoordinate2D)
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
    case getUnlockRecords(lockId: String, type: Int, userId: String, pageIndex: Int, pageSize: Int?) // 获取开门记录 1今天 2昨天 3全部
    case reportAsset(assetId: String, year: String) // 获取报表列表
    case baseTurnoverInfoList(assetId: String, year: String) // 获取流水列表
    case tenantContractInfoAssetContract(assetId: String, year: String) // 资产合同列表
    case reportReportItems(assetId: String, costId: String, year: String) // 获取报名费用类型明细
    case baseTurnoverInfo(assetId: String, contractId: String, payTime: String, itemList: [AddFlowParameter])
    case costCategory // 获取用户的费用类型集合
    case tenantContractInfo(contractId: String) // 获取合租合同详情
    case checkTerminationTenantContract(contractId: String) // 判断是否可以退租
    case terminationContract(contractId: String, billId: String?, accountType: Int, clearDate: String) // 退租 清算方式 1：银行转账 2：微信账号 3：支付宝账号 4：POS机 999：其他账号
    case billInfoClearing(assetId: String, contractId: String, startDate: String, endDate: String) //获取清算账单明细
    case deleteBillInfo(billId: String) // 删除账单
    case editBillInfoClear(parameter: BillLiquidationModel) // 编辑清算账单明细
    case billLandlordList(assetId: String, contractId: String, billStatus: Int?, pageIndex: Int, pageSize: Int)
    case billInfoDetail(billId: String) // 获取账单详情
    case billInfoConfirm(accountType: Int, amount: Double, billId: String, payTime: String, receivingAccountId: String) // 确认到账
    case receivingAccountList // 获取收款账号列表
    case addReceivingAccount(parameter: CollectionAccountModel) // 添加收款账号
    case deleteReceivingAcount(id: String) // 删除收款账号
    case addBillInfo(parameter: CreateBillController.Parameter) // 发起账单
    case addCostCategory(name: String) // 添加用户费用类型
    case contractRenew(contractId: String, endDate: String, increaseType: Int, ratio: Double, rentalChangeType: Int) // 续租 1:按金额 2：按比例  加租: 1 减租: -1
    case editOtherUser(userId: String, userInfo: HandyJSON) // 修改非当前登录用户
    case hardwareBindList(channels: String, pageSize: Int, pageIndex: Int, phoneNo: String) // 获取用户已绑定列表
    case messageList(assetId: String, smsType: Int, pageIndex: Int, pageSize: Int) // 消息中心
    case changePassword(oldPwd: String, newPwd: String) // 修改密码
    case lockTypeList(channels: String) // 获取选择门锁列表
    case stewardList(pageIndex: Int, pageSize: Int?) // 获取管家列表
    case deleteSteward(id: String) // 删除管家
    case addSteward(steward: HouseKeeperModel) // 新增管家
    case editSteward(steward: HouseKeeperModel) // 修改管家
    case findAssetByLockId(id: String) // 查询锁下资产
    case findAssetNotBind // 查询所有未绑定资产
}

