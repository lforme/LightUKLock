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
    
    init() {}
    
    func willSend(_ request: RequestType, target: TargetType) {
        
        DispatchQueue.main.async {[weak self] in
            if !HUD.isVisible {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                guard let this = self else { return }
                HUD.show(.customView(view: this.creatAnimationView()))
            }
        }
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            HUD.hide(afterDelay: 1)
        }
        
    }
    
    private func creatAnimationView() -> UIView {
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
    }
}
