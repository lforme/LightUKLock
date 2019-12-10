//
//  AddFingerController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD

class AddFingerController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var addButton: UIButton!
    let vm = AddFingerViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HUD.hide(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "添加指纹"
        setupUI()
        bind()
    }
    
    func bind() {
        addButton.rx.bind(to: vm.startAction) { (_) -> Void in
            return ()
        }
        
        vm.startAction.elements.subscribe(onNext: {[weak self] (pass) in
            if pass {
                let addFingerFinishVC: AddFingerFinishController = ViewLoader.Storyboard.controller(from: "InitialLock")
                addFingerFinishVC.vm = self?.vm
                self?.navigationController?.pushViewController(addFingerFinishVC, animated: true)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.startAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.startAction.executing.subscribe(onNext: { (exe) in
            if exe {
                HUD.show(.labeledProgress(title: "正在连接蓝牙...", subtitle: nil))
            } else {
                HUD.hide(animated: true)
            }
        }, onError: { (_) in
            HUD.hide(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        addButton.setCircular(radius: addButton.bounds.height / 2)
    }
    
}
