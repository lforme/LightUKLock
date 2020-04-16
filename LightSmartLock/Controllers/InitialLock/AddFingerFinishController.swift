//
//  AddFingerFinishController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import Lottie
import RxCocoa
import RxSwift

class AddFingerFinishController: UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    private var animation: Animation!
    
    var vm: AddFingerViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "完成添加"
        setupAnimationView()
        bind()
    }
    
    func bind() {
        
        guard let userCode = LSLUser.current().scene?.lockUserAccount else {
            HUD.flash(.label("无法从服务器获取用户编号, 请稍后再试"), delay: 2)
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId  else {
            HUD.flash(.label("无法从服务器获取门锁编号, 请稍后再试"), delay: 2)
            navigationController?.popViewController(animated: true)
            return
        }
        
        vm.addFinger().do(onNext: {[weak self] (arg) in
            self?.playAnimation(arg.0 ?? 0)
        }).flatMapLatest {(arg) -> Observable<(Bool, String?)> in
            
            if arg.0 == 4 {
                return Observable<(Bool, String?)>.create { (observer) -> Disposable in
                    BluetoothPapa.shareInstance.conformsFingerAction(userNumber: userCode, pwdNumber: arg.1 ?? "")
                    observer.onNext((true, arg.1))
                    observer.onCompleted()
                    return Disposables.create()
                }.delaySubscription(0.5, scheduler: MainScheduler.instance)
            } else {
                return .empty()
            }
            
        }.flatMapLatest({ (arg) -> Observable<(String, String?)> in
            if arg.0 {
                return Observable<(String, String?)>.create {[weak self] (observer) -> Disposable in
                    
                    guard let this = self else {
                        return Disposables.create()
                    }
                    
                    SingleInputController.rx.present(wiht: "设置指纹名称", saveTitle: "保存", placeholder: "请填写指纹名称").subscribe(onNext: { (name) in
                        observer.onNext((name, arg.1))
                        observer.onCompleted()
                    }).disposed(by: this.rx.disposeBag)
                    
                    return Disposables.create()
                }
            } else {
                return .empty()
            }
        }).flatMapLatest { (arg) -> Observable<Bool> in
            guard let keyNum = arg.1 else {
                return .error(AppError.reason("添加指纹失败, 请在门锁上删除已添加的指纹"))
            }
            return BusinessAPI.requestMapBool(.addFinger(lockId: lockId, keyNum: keyNum, name: arg.0, phone: nil))
            
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                HUD.flash(.label("添加成功"), delay: 2)
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.addFinger)
            } else {
                HUD.flash(.label("添加失败"), delay: 2)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                guard let tagerVC = self?.navigationController?.children.filter({ (vc) -> Bool in
                    return vc is FingerManageController
                }).last else { return }
                self?.navigationController?.popToViewController(tagerVC, animated: true)
            }
            
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                guard let tagerVC = self?.navigationController?.children.filter({ (vc) -> Bool in
                    return vc is FingerManageController
                }).last else { return }
                self?.navigationController?.popToViewController(tagerVC, animated: true)
            }, onCompleted: {[weak self] in
                self?.animationView.play(toProgress: 1)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupAnimationView() {
        animation = Animation.named("addFinger", bundle: Bundle.main, animationCache: LRUAnimationCache.sharedCache)
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        animationView.animation = animation
        animationView.play(fromProgress: 0, toProgress: 0.2, loopMode: .playOnce, completion: nil)
    }
    
    func playAnimation(_ step: Int) {
        switch step {
        case 0:
            animationView.play(fromProgress: 0.2, toProgress: 0.28, loopMode: .playOnce, completion: nil)
        case 1:
            animationView.play(fromProgress: 0.28, toProgress: 0.3, loopMode: .playOnce, completion: nil)
        case 2:
            animationView.play(fromProgress: 0.3, toProgress: 0.38, loopMode: .playOnce, completion: nil)
        case 3:
            animationView.play(fromProgress: 0.38, toProgress: 0.5, loopMode: .playOnce, completion: nil)
        case 4:
            animationView.play(fromProgress: 0.5, toProgress: 1, loopMode: .playOnce, completion: nil)
        default:
            break
        }
    }
}
