//
//  NoLockViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/22.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NoLockViewController: UIViewController {
    
    @IBOutlet weak var mustRead: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var dotView: UIView!
    
    let configuredList = BehaviorRelay<[BindLockListModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkConfigLockList()
    }
    
    func setupUI() {
        dotView.setCircular(radius: 4)
        containerA.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        mustRead.textColor = ColorClassification.textPrimary.value
        
        addButton.setCircular(radius: 7)
        addButton.addTarget(self, action: #selector(self.gotoSelectedLockVC), for: .touchUpInside)
    }
    
    @objc func gotoSelectedLockVC() {
        
        configuredList.subscribe(onNext: {[weak self] (bindLockList) in
            
            if bindLockList.count != 0 {
                let bindLockListVC: BindLockListController = ViewLoader.Storyboard.controller(from: "InitialLock")
                bindLockListVC.dataSource = bindLockList
                self?.navigationController?.pushViewController(bindLockListVC, animated: true)
            } else {
                let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
                selectVC.kind = .edited
                self?.navigationController?.pushViewController(selectVC, animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func checkConfigLockList() {
        if let phone = LSLUser.current().user?.phone {
            BusinessAPI.requestMapJSONArray(.hardwareBindList(channels: "01", pageSize: 100, pageIndex: 1, phoneNo: phone), classType: BindLockListModel.self, useCache: false, isPaginating: true)
                .map { $0.compactMap { $0 } }.catchErrorJustReturn([])
                .bind(to: configuredList)
                .disposed(by: rx.disposeBag)
        }
    }
}
