//
//  MessageNotificationHelper.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit

struct MessageNotificationHelper {
    
    enum MessageType {
        case success
        case failed
        case error
        case warning
        case noti
    }
    
    static func showMessageOnTop(_ message: String, title: String, type: MessageType) {
        
        let minEdge = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)

        
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .gradient(gradient: .init(colors: [EKColor(.red), EKColor(.green)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: minEdge), height: .intrinsic)

        let _title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 18, weight: .heavy), color: EKColor(ColorClassification.textPrimary.value)))
        let _description = EKProperty.LabelContent(text: message, style: .init(font: UIFont.systemFont(ofSize: 14, weight: .heavy), color: EKColor(ColorClassification.textOpaque78.value)))
        
        let simpleMessage = EKSimpleMessage.init(title: _title, description: _description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
