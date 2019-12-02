//
//  AnimationHeaderView.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Lottie
import Then
import LTMorphingLabel
import RxCocoa
import RxSwift

class AnimationHeaderView: UITableViewCell {
    
    @IBOutlet weak var animationView: AnimationView!
    
    private var animationError: Animation!
    private var animationLowpower: Animation!
    private var animationNormal: Animation!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: LTMorphingLabel!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    private let timer = Observable<Int>.timer(1, period: 3, scheduler: MainScheduler.instance)
    private var count = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        animationError = Animation.named("error", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        animationLowpower = Animation.named("warning", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                animationNormal = Animation.named("normalDarkMode", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
            } else {
                animationNormal = Animation.named("normal", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
            }
        } else {
            animationNormal = Animation.named("normal", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        }
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animation = animationNormal
        animationView.play()
        
        contentLabel.morphingEffect = .pixelate
        self.contentView.backgroundColor = ColorClassification.viewBackground.value
        
        UIApplication.shared.rx
            .didBecomeActive
            .subscribe(onNext: {[weak self] _ in
                self?.animationView.play()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.animationRestart)
            .takeUntil(rx.deallocated)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                self?.animationView.play()
            }).disposed(by: disposeBag)
    }
    
    func bind(_ data: IOTLockInfoModel?) {
        guard let model = data else {
            return
        }
        if model.OnLineState == 0 {
            animationView.animation = animationError
            animationView.play()
            titleLabel.text = "运行异常"
            contentLabel.text = "门锁无法和云端通信"
        }
        
        if let power = model.PowerPercent {
            if power < 0.20 {
                animationView.animation = animationLowpower
                animationView.play()
                titleLabel.text = "电量低"
                contentLabel.text = "门锁电量:\(model.getPower() ?? "")"
            }
        }
        
        if let days = model.DaysInt, let powerValue = model.getPower() {
            let sentenceOne = "电池预估能用\(days)天"
            let sentenceTwo = "剩余电量\(powerValue)"
            timer.delaySubscription(5, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
                guard let this = self else { return }
                if this.count {
                    this.contentLabel.text = sentenceOne
                } else {
                    this.contentLabel.text = sentenceTwo
                }
                this.count = !this.count
            }).disposed(by: disposeBag)
        }
    }
}
