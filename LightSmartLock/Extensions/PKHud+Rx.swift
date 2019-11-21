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

extension Reactive where Base: PKHUD {
    
    var showError: Binder<AppError?> {
        return Binder(self.base, scheduler: MainScheduler.instance, binding: { (_, error) in
            if let e = error {
                HUD.flash(.label(e.message), delay: 2)
            }
        })
    }
}

