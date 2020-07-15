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

class SoundSettingController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
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
        
        let oldVolume = LocalArchiver.load(key: LSLUser.Keys.bluetoothVolume.rawValue) as? Int ?? 2
        sliderView.value = Float(oldVolume)
        
        sliderView.rx.value.throttle(.seconds(1), scheduler: MainScheduler.instance).map { Int($0) }.subscribe(onNext: {[weak self] (volume) in
            self?.vm.setVolume(volume)
            LocalArchiver.save(key: LSLUser.Keys.bluetoothVolume.rawValue, value: volume)
        }).disposed(by: rx.disposeBag)
    }
}
