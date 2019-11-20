//
//  OpenDoorViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Lottie

class OpenDoorViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var label: UILabel!
    var animation: Animation!
    @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var animationViewWidth: NSLayoutConstraint!
    @IBOutlet weak var animationViewTopOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadFinddingAnimationJson()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loadOpendoorAnimationJson()
        }
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
    }
    
    @IBAction func backTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadFinddingAnimationJson() {
        label.text = "正在寻找蓝牙..."
        animationViewTopOffset.constant = 8.0
        animationViewWidth.constant = 300.0
        animationViewHeight.constant = 300.0
        animation = Animation.named("bluetooth", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        animationView.loopMode = .loop
        animationView.animation = animation
        animationView.play()
    }
    
    func loadOpendoorAnimationJson() {
        label.text = "正在开门..."
        animationViewTopOffset.constant = 70.0
        animationViewWidth.constant = 160.0
        animationViewHeight.constant = 160.0
        animation = Animation.named("opendoor", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        animationView.loopMode = .playOnce
        animationView.animation = animation
        animationView.play {[weak self] (finish) in
            if finish {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
