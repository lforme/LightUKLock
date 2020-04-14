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
    
    var kind: SelectLockTypeController.AddKind!
    
    let vm = LockStartScanViewModel()    
    var lockInfo: LockModel!
    
    fileprivate var shouldIgnorePushingViewControllers = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldIgnorePushingViewControllers = false
    }
    
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
        
        let shareConnected = vm.scanAction.elements.share(replay: 1, scope: .forever)
        
        shareConnected.subscribe(onNext: { (success) in
            if success {
                BluetoothPapa.shareInstance.handshake {[weak self] (data) in
                    let tuple = BluetoothPapa.serializeShake(data)
                    self?.lockInfo.bluetoothName = tuple?.Mac
                    self?.lockInfo.blueMac = tuple?.Mac
                    self?.lockInfo.lockNum = tuple?.Mac
                }
            }
        }).disposed(by: rx.disposeBag)
        
        shareConnected.delay(1, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (success) in
            if success {
                if self?.shouldIgnorePushingViewControllers ?? false {
                    return
                }
                let setPwdVC: LockSettingPasswordController = ViewLoader.Storyboard.controller(from: "InitialLock")
                
                setPwdVC.kind = self?.kind
                setPwdVC.lockInfo = self?.lockInfo
                self?.navigationController?.pushViewController(setPwdVC, animated: true)
                self?.shouldIgnorePushingViewControllers = true
                HUD.hide(animated: true)
            } else {
                HUD.flash(.label("未找到蓝牙门锁,请稍后再试"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.scanAction.executing.subscribe(onNext: { (exe) in
            if exe {
                HUD.show(.label("蓝牙连接中..."))
            }
        }, onCompleted: {
            HUD.hide(animated: true)
        }) {
            HUD.hide(animated: true)
        }.disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        scanButton.setCircular(radius: scanButton.bounds.height / 2)
    }
}
