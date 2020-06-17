//
//  ResetLockController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift

class ResetLockController: UIViewController, NavigationSettingStyle {
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var forceDeleteButton: UIButton!
    @IBOutlet weak var notiLabel: UILabel!
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    var vm: LockSettingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "恢复出厂设置"
        bind()
    }
    
    func bind() {
        stepLabel.text = """
        1.打开门锁内面板长按“复位”键，待门锁发出指令后松手。
        2.根据门锁指令操作恢复出厂设置。
        3.等待门锁恢复出厂设置完成后，点击本页强制删除设备按钮。
        """
        notiLabel.text = """
        重要提示：
        若门锁已恢复出厂设置，请直接点击“强制删除设备”按钮。
        """
        
        forceDeleteButton.rx.tap.flatMapLatest {[unowned self] (_) -> Observable<Int> in
            self.showActionSheet(title: "确定要强制删除门锁吗?", message: "强制删除门锁并不会重置门锁设置, 需要您手动在门锁上恢复出厂设置", buttonTitles: ["强制删除", "取消"], highlightedButtonIndex: 1)
        }.flatMapLatest {[unowned self] (buttonIndex) -> Observable<Bool> in
            return self.vm.forceDeleteLock(buttonIndex)
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                self?.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.deleteLock)
                var updateValue = LSLUser.current().scene
                updateValue?.ladderLockId = nil
                LSLUser.current().scene = updateValue
                LSLUser.current().lockInfo = nil
                
            } else {
                HUD.flash(.label("删除门锁失败"), delay: 2)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
}
