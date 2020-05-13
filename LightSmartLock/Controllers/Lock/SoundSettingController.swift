//
//  SoundSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class SoundSettingController: UIViewController {
    
    @IBOutlet weak var sliderView: UISlider!
    
    var vm: LockSettingViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "门锁音量"
        bind()
    }
    
    func bind() {
        
        sliderView.rx.value.throttle(.seconds(1), scheduler: MainScheduler.instance).map { Int($0) }.subscribe(onNext: {[weak self] (volume) in
            self?.vm.setVolume(volume)
        }).disposed(by: rx.disposeBag)
    }
}
