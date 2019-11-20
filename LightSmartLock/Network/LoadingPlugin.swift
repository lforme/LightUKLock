//
//  LoadingPlugin.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Moya
import PKHUD
import Lottie

final class LoadingPlugin: PluginType {
    
    private let animationView: AnimationView
    private let animation: Animation
    private let view: UIView
    
    init() {
        
        animation = Animation.named("loading", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)!
        animationView = AnimationView(animation: animation)
        animationView.frame.size = CGSize(width: 40, height: 40)
        animationView.animation = animation
        animationView.loopMode = .loop
        animationView.play()
        view = UIView()
        view.frame.size = CGSize(width: 50, height: 50)
        animationView.center = view.center
        view.addSubview(animationView)
        
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        
        DispatchQueue.main.async {[weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            guard let this = self else { return }
            HUD.show(.customView(view: this.view))
        }
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            HUD.hide(afterDelay: 0.5)
        }
    }
    
}
