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
    var homeTabBarVC: ESTabBarController?
    
    
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
        
        homeTabBarVC = ESTabBarController()
        homeTabBarVC?.title = "主页"
        homeTabBarVC?.tabBar.shadowImage = UIImage.from(color: #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 0.48))
        homeTabBarVC?.tabBar.backgroundImage = UIImage.from(color: ColorClassification.viewBackground.value)
        
        homeTabBarVC?.shouldHijackHandler = { tabVC, vc, index in
            if index == 1 {
                return true
            }
            return false
        }
        
        homeTabBarVC?.didHijackHandler = {[weak self] tabVC, vc, Index in
            
            if LSLUser.current().lockInfo == nil {
                HUD.flash(.label("请先绑定门锁"), delay: 2)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let openDoorVC: OpenDoorViewController = ViewLoader.Xib.controller()
                self?.homeTabBarVC?.present(openDoorVC, animated: true, completion: nil)
            }
        }
        
        let home: HomeViewController = ViewLoader.Storyboard.controller(from: "Home")
        let open = UIViewController()
        let my: MyViewController = ViewLoader.Storyboard.controller(from: "My")
        
        home.tabBarItem = ESTabBarItem(CustomizedTabbarItem(), title: "门锁助手", image: UIImage(named: "tabbar_home"), selectedImage: UIImage(named: "tabbar_home"), tag: 0)
        open.tabBarItem = ESTabBarItem(CustomizedOpenDoorItem(), title: nil, image: UIImage(named: "tabbar_open_door"), selectedImage: UIImage(named: "tabbar_open_door"), tag: 1)
        my.tabBarItem = ESTabBarItem(CustomizedTabbarItem(), title: "个人中心", image: UIImage(named: "tabbar_my"), selectedImage: UIImage(named: "tabbar_my"), tag: 2)
       
        
        let vcs = [home, open, my].map { BaseNavigationController(rootViewController: $0) }
        homeTabBarVC?.viewControllers = vcs
        
        self.view.addSubview(homeTabBarVC!.view)
        self.addChild(homeTabBarVC!)
        
        homeTabBarVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
    }
    
    func showLoginVC() {
        homeTabBarVC?.view.removeFromSuperview()
        homeTabBarVC?.removeFromParent()
        homeTabBarVC = nil
        
        let temp: LoginViewController = ViewLoader.Storyboard.controller(from: "Login")
        loginVC = BaseNavigationController(rootViewController: temp)
        self.view.addSubview(loginVC!.view)
        loginVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
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

