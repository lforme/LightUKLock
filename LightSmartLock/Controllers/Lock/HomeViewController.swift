//
//  HomeViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Lottie
import PKHUD
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var noLockView: UIView!

    let vm: HomeViewModeling = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "门锁助手"
        self.extendedLayoutIncludesOpaqueBars = true
        bind()
        setupUI()
    }
    
    func setupUI() {
        noLockView.alpha = 0
    }
    
    func bind() {
        vm.isInstallLock.subscribeOn(MainScheduler.instance).subscribe(onNext: {[unowned self] (isInstalled) in
            self.hasLock(has: isInstalled)
            }, onError: {[unowned self] (error) in
                Observable.error(error).bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
    }
    
    private func hasLock(has: Bool) {
        if has {
            noLockView.alpha = 0
            self.tabBarController?.tabBar.isHidden = false
            self.extendedLayoutIncludesOpaqueBars = false
        } else {
            noLockView.alpha = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
}
