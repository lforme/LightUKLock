//
//  NetworkInterface.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

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
    case uploadImage(UIImage, description: String) // 图片上传
    case getCustomerSceneList(pageIndex: Int, pageSize: Int?, Sort: Int?) // 获取场景列表
    case getCurrentCustomerInfo(sceneID: String) //获取用户在一个场景下的身份
    case getLockInfoBySceneID // 根据场景ID获取门锁绑定信息
    case getLockCurrentInfoFromIOTPlatform // 从物联网平台获取门锁信息
    case getUnlockLog(userCodes: [String], beginTime: String?, endTime: String?, index: Int, pageSize: Int?) //解锁记录
    case updateUserInfo(info: UserModel) // 更户信息
    case submitBluthUnlockOperation // 上传蓝牙解锁记录
    case getLockNotice(noticeType: [Int], noticeLevel: [Int], pageIndex: Int, pageSize: Int?) // 获取消息提醒 noticeType = -1 全部  noticeLevel = -1 全部
    case unInstallLock // 删除蓝牙门锁
    case getSceneAssets // 获取资产详情
    case addOrUpdateSceneAsset(parameter: PositionModel) // 新增,编辑 资产位置信息
    case deleteSceneAssetsBySceneId(String) // 删除资产
    case uploadLockConfigInfo(info: SmartLockInfoModel) // 上传蓝牙门锁绑定信息
    case getCustomerMemberList(pageIndex: Int, pageSize: Int?) // 获取成员列表
    case getCustomerKeyFirst(type: Int) // 密码管理页面
    case getKeyStatusChangeLogByKeyId(keyID: String, index: Int, pageSize: Int?) // 密码详情变更状态
    case updateCustomerCodeKey(secret: String, isRemote: Bool?) // 更新我的密码
    case getFingerPrintKeyList(customerId: String, index: Int, pageSize: Int?)
    case setFingerCoercionReminPhone(id: String, phone: String) // 设置为胁迫指纹
    case setFingerCoercionToNormal(id: String) // 设置为正常指纹
    case setFingerRemark(id: String, fingerName: String) // 设置指纹名称
    case deleteFingerPrintKey(id: String, isRemote: Bool) // 删除指纹
    case addFingerPrintKey(name: String) // 添加指纹
    case getCustomerKeyList(keyType: Int, index: Int, pageSize: Int?) // 密码列表
    case addCustomerCard(KeyNumber: String, remark: String?) //添加门卡
    case setCardRemark(keyId: String, remark: String) // 更新门卡名称
    case deleteCustomerCard(keyId: String) // 删除门卡
    case getCustomerSysRoleTips // 获取系统内置标签
    case addCustomerMember(member: AddUserMemberModel) // 添加成员
    case updateCustomerNameById(id: String, name: String)
    case deleteCustomerMember(customerID: String, isRemote: Bool?) // 删除成员
    case getTempKeyShareList(customerID: String, pageIndex: Int, pageSize: Int?) // 获取临时密码列表
    case getTempKeyShareLog(shareID: String) // 获取临时密码分享记录
    case retractTempKeyShare(shareID: String) // 撤回分享内容
    case generateTempBy(input: TempPasswordShareParameter) // 分享
    
    
    // 新添加的
    case user // 获取当前用户信息
    case getHouses // 获取资产列表
}
