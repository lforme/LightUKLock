//
//  SettingWithoutLockController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/2.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class SettingWithoutLockController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let configuredList = BehaviorRelay<[BindLockListModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "资产"
        setupUI()
    }
    
    func setupUI() {
        clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 8
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let editAssetVC: BindingOrEditAssetViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
            editAssetVC.assetId = LSLUser.current().scene?.ladderAssetHouseId ?? ""
            self.navigationController?.pushViewController(editAssetVC, animated: true)
        }
        
        if indexPath.section == 1 {
            
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
