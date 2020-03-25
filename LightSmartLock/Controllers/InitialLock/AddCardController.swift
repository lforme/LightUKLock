//
//  AddCardController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift

class AddCardController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    
    let vm = AddCardViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "添加门卡"
        setupUI()
        bind()
    }
    
    func bind() {
        addButton.rx.bind(to: vm.startScanAction, input: ())
        
        vm.startScanAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.startScanAction.executing.subscribe(onNext: { (exe) in
            if exe {
                HUD.show(.labeledProgress(title: "正在连接蓝牙...", subtitle: nil))
            } else {
                HUD.hide(afterDelay: 1.2)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.startScanAction.elements.flatMapLatest {[unowned self] (success) -> Observable<String> in
            if success {
                return self.vm.addCard()
            } else {
                return .empty()
            }
        }.flatMapLatest {[unowned self] (keyNumber) -> Observable<(String, String)> in
            
            return Observable<(String, String)>.create { (observer) -> Disposable in
                
                SingleInputController.rx.present(wiht: "设置门卡称", saveTitle: "保存", placeholder: "请填写门卡备注").subscribe(onNext: { (cardName) in
                    observer.onNext((keyNumber, cardName))
                    observer.onCompleted()
                }).disposed(by: self.rx.disposeBag)
                
                return Disposables.create()
            }
        }.flatMapLatest {[unowned self] (arg) -> Observable<Bool> in
            return self.vm.setCardName(arg.1, keyNumber: arg.0)
        }.subscribe(onNext: { (success) in
            if success {
                HUD.flash(.label("添加成功"), delay: 2)
            } else {
                HUD.flash(.label("添加失败"), delay: 2)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
            
        }, onError: { (error) in
            PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        addButton.setCircular(radius: addButton.bounds.height / 2)
    }
}
