//
//  MyVCNavigationControllerDelegate.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/16.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class MyVCNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var shrinkAnimator: MyViewControllerShrinkAnimation?
    var expandAnimator: MyViewControllerExpandAnimation?
    lazy var interactiveTransition = UIPercentDrivenInteractiveTransition()
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
       
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop, let _ = fromVC as? HomeViewController, let _ = toVC as? MyViewController {

            self.shrinkAnimator = MyViewControllerShrinkAnimation()
            
            return self.shrinkAnimator!
        }
        
        if operation == .push, let myVC = fromVC as? MyViewController, let _ = toVC as? HomeViewController {
            
            self.expandAnimator = MyViewControllerExpandAnimation(thumbView: myVC.clickCell!)
            
            return self.expandAnimator!
        }
        
        return nil
    }
}
