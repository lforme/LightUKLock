//
//  LockStartScanningController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift

class LockStartScanningController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    let vm = LockStartScanViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "添加门锁"
        setupUI()
        bind()
        
        
        
    }
    
    func bind() {
        desLabel.text = "注意事项:\n1.打开门锁内面版长按[功能键], 待门锁发出[请打开手机蓝牙和APP]后松手.\n2.请务必站在门锁前方打开手机蓝牙进行绑定."
        
        vm.setupAction()
        
        scanButton.rx.bind(to: vm.scanAction, input: ())
        
        vm.scanAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.scanAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                let setPwdVC: LockSettingPasswordController = ViewLoader.Storyboard.controller(from: "InitialLock")
                self?.navigationController?.pushViewController(setPwdVC, animated: true)
            } else {
                HUD.flash(.label("未找到蓝牙门锁,请稍后再试"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.scanAction.executing.subscribe(onCompleted: {
            print("completed")
        }) {
            print("disp")
        }.disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        scanButton.setCircular(radius: scanButton.bounds.height / 2)
    }
}
