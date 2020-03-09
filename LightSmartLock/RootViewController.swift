//
//  RootViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/18.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SnapKit
import RxCocoa
import RxSwift
import NSObject_Rx
import PKHUD

class RootViewController: UIViewController {
    
    var loginVC: BaseNavigationController?
    var homeNavigationVC: BaseNavigationController?
    
    fileprivate var _statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self._statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeStatusBarChanged()
        observerLoginStatus()
        checkLoginStatus()
        observerSiriOpenDoor()
    }
    
    func observerSiriOpenDoor() {
        NotificationCenter.default.rx.notification(.siriOpenDoor)
        .takeUntil(rx.deallocated)
        .observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
        .subscribe(onNext: {[weak self] (_) in
            self?.openDoor()
        }).disposed(by: rx.disposeBag)
    }
    
    func checkLoginStatus() {
        if LSLUser.current().isLogin {
            showHomeTabbar()
        } else {
            showLoginVC()
        }
    }
    
    func showHomeTabbar() {
        loginVC?.view.removeFromSuperview()
        loginVC?.removeFromParent()
        loginVC = nil
        
        let my: MyViewController = ViewLoader.Storyboard.controller(from: "My")
        homeNavigationVC = BaseNavigationController(rootViewController: my)
    
        self.view.addSubview(homeNavigationVC!.view)
        self.addChild(homeNavigationVC!)
        
        homeNavigationVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
    }
    
    func showLoginVC() {
        homeNavigationVC?.view.removeFromSuperview()
        homeNavigationVC?.removeFromParent()
        homeNavigationVC = nil
        
        let temp: LoginViewController = ViewLoader.Storyboard.controller(from: "Login")
        loginVC = BaseNavigationController(rootViewController: temp)
        self.view.addSubview(loginVC!.view)
        loginVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
    }
    
    func openDoor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            let openDoorVC: OpenDoorViewController = ViewLoader.Xib.controller()
            self?.homeNavigationVC?.present(openDoorVC, animated: true, completion: nil)
        }
    }
    
    
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? BaseNavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? ESTabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

/// 观察方法
extension RootViewController {
    
    func observeStatusBarChanged() {
        
        NotificationCenter.default.rx.notification(.statuBarDidChange)
            .takeUntil(rx.deallocated)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                if let style = noti.object as? UIStatusBarStyle {
                    self?._statusBarStyle = style
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func observerLoginStatus() {
        
        NotificationCenter.default.rx.notification(.loginStateDidChange).takeUntil(rx.deallocated)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (objc) in
                guard let isLogin = objc.object as? Bool else { return }
                if isLogin {
                    self?.showHomeTabbar()
                } else {
                    self?.showLoginVC()
                }
            }).disposed(by: rx.disposeBag)
    }
}

