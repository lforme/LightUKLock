//
//  ReceivingAccountController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class ReceivingAccountController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "收款账号"
        setupUI()
    }
    
    func setupUI() {
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80.0
        tableView.register(UINib.init(nibName: "ReceivingAccountCell", bundle: nil), forCellReuseIdentifier: "ReceivingAccountCell")
        
        // testCode
        let items: Observable<[Int]> = Observable.just([1, 2, 3])
        
        items.bind(to: tableView.rx
            .items(cellIdentifier: "ReceivingAccountCell", cellType: ReceivingAccountCell.self)) { (row, num, cell) in
                
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[unowned self] (ip) in
            switch ip.row {
            case 0:
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = true
                paywayBindVC.payWay = .wechat
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
            case 1:
                let paywayBindVC: PayWayBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = false
                paywayBindVC.payWay = .ali
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
                
            case 2:
                let paywayBindVC: BankCardBindController = ViewLoader.Storyboard.controller(from: "Bill")
                paywayBindVC.canEditing = false
                self.navigationController?.pushViewController(paywayBindVC, animated: true)
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
}
