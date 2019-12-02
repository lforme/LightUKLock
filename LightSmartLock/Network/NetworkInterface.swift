//
//  NetworkInterface.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

enum AuthenticationInterface {
    
    case login(userName: String, password: String) // 用户面密码登录
    case token // 登录前获取Token, 用于平台登录
    case MSMFetchCode(phone: String) // 获取短信
    case validatePhoneCode(phone: String, code: String) // 注册
    case getAccountInfoByPhone(phone: String) // 获取用户信息
    case updateLoginPassword(password: String, accountId: String) // 设置密码
    case userToken(userName: String, pwd: String) // 登录成功之后获取用户token
    case refreshPlatformToken // 401刷新token
    case refreshUserToken // 401刷新token
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
}
