//
//  MyViewControllerShrinkAnimation.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/16.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class MyViewControllerShrinkAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        let finalFrameForVc = transitionContext.finalFrame(for: toVC!)
        toVC?.view.frame = finalFrameForVc.offsetBy(dx: 0, dy: -(UIScreen.main.bounds.size.height))
        transitionContext.containerView.addSubview(toVC!.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            toVC?.view?.frame = finalFrameForVc
            
        }) { (finished) in
            if !transitionContext.transitionWasCancelled {
                fromVC?.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            } else {
                toVC?.view.removeFromSuperview()
                transitionContext.completeTransition(false)
            }
        }
        
    }
}
