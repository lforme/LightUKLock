//
//  ShareTool.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import PKHUD

struct ShareTool {
    
    enum Platform {
        case qq
        case weixin
    }
    
    static func share(platform: Platform, contentText: String?,
                      url: String?, title: String?, images: [UIImage?] = [nil], shareResult: @escaping (Bool) -> Void) {
        
        let shareParams = NSMutableDictionary()
        shareParams.ssdkSetupShareParams(byText: contentText ?? "", images: images, url: URL(string: url ?? ""), title: title ?? "", type: SSDKContentType.auto)
        
        switch platform {
        case .weixin:
            ShareSDK.share(.subTypeWechatSession, parameters: shareParams) { (state, info, entity, error) in
                switch state {
                case .success:
                    shareResult(true)
                default:
                    shareResult(false)
                }
            }
            
        case .qq:
            ShareSDK.share(.subTypeQQFriend, parameters: shareParams) { (state, info, entity, error) in
                switch state {
                case .success:
                    shareResult(true)
                default:
                    shareResult(false)
                }
            }
        }
    }
}
