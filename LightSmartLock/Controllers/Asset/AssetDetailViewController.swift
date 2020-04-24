//
//  AssetDetailViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Popover

class AssetDetailViewController: UIViewController {
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("删除", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    lazy var popView: UIView = {
        let view = UIStackView(arrangedSubviews: [self.deleteBtn])
        view.frame = CGRect(x: 0, y: 0, width: 64, height: 34)
        return view
    }()
    
    lazy var popover: Popover = {
        let popover = Popover()
        popover.popoverColor = UIColor.black.withAlphaComponent(0.8)
        return popover
    }()
    
    @IBOutlet weak var moreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreButton.rx
            .tap
            .subscribe(onNext: { [unowned self](_) in
                self.popover.show(self.popView, fromView: self.moreButton)
            })
            .disposed(by: rx.disposeBag)
        
        deleteBtn.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                self?.popover.dismiss()
                
                let alertController = UIAlertController(title: "提示", message: "请先删除资产中的门锁", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                    print("test")
                }
                alertController.addAction(confirmAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
