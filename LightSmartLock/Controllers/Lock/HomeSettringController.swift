//
//  HomeSettingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class HomeSettingController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let currentAsset = BehaviorSubject<PositionModel?>(value: nil)
    
    enum SeletType: Int {
        case lockSetting = 0
        case lockInfo
        case position
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "门锁设置"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
        bind()
    }
    
    func bind() {
        if let assetId = LSLUser.current().scene?.ladderAssetHouseId {
            BusinessAPI
                .requestMapJSON(.getAssetHouseDetail(id: assetId), classType: PositionModel.self)
                .bind(to: currentAsset)
                .disposed(by: rx.disposeBag)
            
            currentAsset.subscribe(onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SeletType(rawValue: indexPath.row + (indexPath.section * 10)) else {
            return
        }
        
        switch type {
        case .lockSetting:
            let lockSettingVC: LockSettingController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockSettingVC, animated: true)
            
        case .lockInfo:
            let lockInfoVC: LockInfoController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockInfoVC, animated: true)
            
        case .position:
            let editAssetVC: BindingOrEditAssetViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
            
            if let asset = try? currentAsset.value() {
                editAssetVC.asset = asset
            }
            navigationController?.pushViewController(editAssetVC, animated: true)
        }
    }
}
