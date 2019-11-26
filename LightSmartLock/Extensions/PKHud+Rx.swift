//
//  PKHud+Rx.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/21.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import PKHUD
import RxCocoa
import RxSwift
import Action

extension Reactive where Base: PKHUD {
    
    func showAppError(_ error: AppError?) {
        if let e = error {
            HUD.flash(.label(e.message), delay: 2)
        }
    }
    
    func showActionError(_ error: ActionError) {
        switch error {
        case let .underlyingError(appError):
            if let e = appError as? AppError {
                HUD.flash(.label(e.message), delay: 2)
            } else {
                HUD.flash(.label(appError.localizedDescription), delay: 2)
            }
        default:
            break
        }
    }
    
    
    func showError(_ error: Error?) {
        if let e = error as? AppError {
            HUD.flash(.label(e.message), delay: 2)
        } else {
            HUD.flash(.label(error.debugDescription), delay: 2)
        }
    }
}

