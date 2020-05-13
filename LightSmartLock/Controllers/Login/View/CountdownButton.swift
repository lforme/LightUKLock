//
//  CountdownButton.swift
//  CDCISteward
//
//  Created by 木瓜 on 2018/3/19.
//  Copyright © 2018年 UOKO. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CountdownButton: UIButton {
    
    private var count = Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance).share()
    private var cancelDisposable: Disposable?
    
    func startCount() {
       cancelDisposable = count.take(60)
            .map { 60 - $0 }
            .do(onNext: {[unowned self] (v) in
                self.isEnabled = v > 0 ? false : true
            }).map({ (second) -> String in
                return "重新发送\(second)秒"
            })
            .asDriver(onErrorJustReturn: "发生错误")
            .drive(onNext: {[unowned self] (txt) in
                self.setTitle(txt, for: .disabled)
                }, onCompleted: {
                    self.isEnabled = true
                    self.setTitle("重新发送", for: .normal)
            })
    }
    
    func reset() {
        self.isEnabled = true
        self.setTitle("重新发送", for: .normal)
        cancelDisposable?.dispose()
    }
    
    deinit {
        reset()
    }
}
