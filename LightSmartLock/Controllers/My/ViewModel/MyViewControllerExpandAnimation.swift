//
//  MyViewControllerExpandAnimation.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/16.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class MyViewControllerExpandAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private weak var thumbView: UITableViewCell?
    
    convenience init(thumbView: UITableViewCell?) {
        self.init()
        self.thumbView = thumbView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let thumbView = self.thumbView else {
            return
        }
        
        let toVC = transitionContext.viewController(forKey: .to)
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let thumbFrame = transitionContext.containerView.convert(thumbView.bounds, from: thumbView)
        toView?.frame = thumbFrame
        
        transitionContext.containerView.addSubview(toView!)
        
        let toViewFinalFrame = transitionContext.finalFrame(for: toVC!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            toView?.frame = toViewFinalFrame
            
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
