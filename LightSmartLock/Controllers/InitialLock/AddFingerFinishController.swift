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
        
        guard let userCode = LSLUser.current().userInScene?.userCode else {
            HUD.flash(.label("无法从服务器获取用户编号, 请稍后再试"), delay: 2)
            navigationController?.popViewController(animated: true)
            return
        }
        
        vm.addFinger().do(onNext: {[weak self] (arg) in
            self?.playAnimation(arg.0 ?? 0)
            guard let pwdNumber = arg.1 else { return }
            if var localInfo = LSLUser.current().userInScene {
                localInfo.pwdNumber = pwdNumber
                LSLUser.current().userInScene = localInfo
            }
            
        }).flatMapLatest { (arg) -> Observable<Bool> in
            print(arg)
            if arg.0 == 4 {
                return Observable<Bool>.create { (observer) -> Disposable in
                    BluetoothPapa.shareInstance.conformsFingerAction(userNumber: userCode, pwdNumber: arg.1 ?? "")
                    observer.onNext(true)
                    observer.onCompleted()
                    return Disposables.create()
                }.delaySubscription(0.5, scheduler: MainScheduler.instance)
            } else {
                return .empty()
            }
            
        }.flatMapLatest({ (success) -> Observable<String> in
            if success {
                return SingleInputController.rx.present(wiht: "设置指纹名称", saveTitle: "保存", placeholder: "请填写指纹名称")
            } else {
                return .empty()
            }
        }).flatMapLatest { (name) -> Observable<Bool> in
                if name.count > 0 {
                    return BusinessAPI.requestMapBool(.addFingerPrintKey(name: name))
                } else {
                    return .empty()
                }
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                HUD.flash(.label("添加成功"), delay: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                HUD.flash(.label("添加失败"), delay: 2)
            }
            
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?.navigationController?.popToRootViewController(animated: true)
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
