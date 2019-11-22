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
    
    var showError: Binder<AppError?> {
        return Binder(self.base, scheduler: MainScheduler.instance, binding: { (_, error) in
            if let e = error {
                HUD.flash(.label(e.message), delay: 2)
            }
        })
    }
    
    var showActionError: Binder<ActionError> {
        return Binder(self.base, scheduler: MainScheduler.instance, binding: { (_, error) in
            switch error {
            case let .underlyingError(appError):
                if let e = appError as? AppError {
                    HUD.flash(.label(e.message), delay: 2)
                }
            default: break
            }
        })
    }
}

