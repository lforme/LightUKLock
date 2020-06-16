//
//  MyViewControllerShrinkAnimation.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/16.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class MyViewControllerShrinkAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private weak var thumbView: UIButton?
    
    convenience init(thumbView: UIButton?) {
        self.init()
        self.thumbView = thumbView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let thumbView = self.thumbView else {
            return
        }
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let thumbFrame = transitionContext.containerView.convert(thumbView.bounds, from: thumbView)
        
        transitionContext.containerView.insertSubview(toView!, belowSubview: fromView!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            fromView?.frame = thumbFrame
        }) { (finished) in
            if !transitionContext.transitionWasCancelled {
                fromView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            } else {
                toView?.removeFromSuperview()
                transitionContext.completeTransition(false)
            }
        }
    }
}
