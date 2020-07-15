//
//  LSLWebViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import WebKit
import PKHUD
import Lottie

class LSLWebViewController: UIViewController {
    
    lazy var animation: UIView = {
        let animation = Animation.named("loading", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)!
        let animationView = AnimationView(animation: animation)
        animationView.frame.size = CGSize(width: 50, height: 50)
        animationView.animation = animation
        animationView.loopMode = .loop
        animationView.play()
        let view = UIView()
        view.frame.size = CGSize(width: 50, height: 50)
        animationView.center = view.center
        view.addSubview(animationView)
        view.backgroundColor = ColorClassification.hudColor.value
        return view
    }()
    
    var navigationTitile: String?
    var webUrl: String?
    var webView: WKWebView!
    
    deinit {
        print("deinit \(self)")
    }
    
    convenience init(navigationTitile: String?, webUrl: String?) {
        self.init()
        self.navigationTitile = navigationTitile
        self.webUrl = webUrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = navigationTitile
        setupUI()
    }
    
    func setupUI() {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 50))
        webView.contentMode = .scaleAspectFit
        view.addSubview(webView)
        let url = URL(string: webUrl ?? "")
        guard let u = url else {
            return
        }
        webView.load(URLRequest(url: u))
        webView.navigationDelegate = self
        HUD.show(.customView(view: animation))
    }
}

extension LSLWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HUD.hide(afterDelay: 1)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        PKHUD.sharedHUD.rx.showError(error)
    }
    
}
