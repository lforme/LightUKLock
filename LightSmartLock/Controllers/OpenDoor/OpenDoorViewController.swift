//
//  OpenDoorViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Lottie
import RxCocoa
import RxSwift
import PKHUD

class OpenDoorViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    var animation: Animation!
    @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var animationViewWidth: NSLayoutConstraint!
    @IBOutlet weak var animationViewTopOffset: NSLayoutConstraint!
    
    let vm = OpenDoorViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadFinddingAnimationJson()
        bind()
    }
    
    func bind() {
        
        let shareConnected = vm.startConnected.share(replay: 1, scope: .forever)
        
        shareConnected.subscribe(onNext: { (connect) in
            if connect {
                BluetoothPapa.shareInstance.handshake { (data) in
                    print(data ?? "握手失败")
                }
            }
        }).disposed(by: rx.disposeBag)
        
        shareConnected.delaySubscription(2, scheduler: MainScheduler.instance).flatMapLatest {[weak self] (isConnected) -> Observable<Bool> in
            guard let this = self else {
                return .error(AppError.reason("解锁失败"))
            }
            if isConnected {
                return this.vm.openDoor()
            } else {
                return .just(false)
            }
        }.flatMapLatest {[weak self] (openDoorSuccess) -> Observable<Bool> in
            guard let this = self else {
                return .error(AppError.reason("解锁失败"))
            }
            if openDoorSuccess {
                return this.vm.uploadUnlockRecord()
            } else {
                return .just(false)
            }
        }.subscribe(onNext: {[weak self] (finished) in
            print("successful open")
            self?.loadOpendoorAnimationJson()
        }, onError: {[weak self] (error) in
            PKHUD.sharedHUD.rx.showError(error)
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        label.textColor = ColorClassification.textPrimary.value
        desLabel.textColor = ColorClassification.textOpaque78.value
        backButton.layer.transform = CATransform3DMakeRotation(.pi * 3 / 2, 0, 0, 1)
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
        animationView.animationSpeed = 1
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
        animationView.animationSpeed = 2
        animationView.play {[weak self] (finish) in
            if finish {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
