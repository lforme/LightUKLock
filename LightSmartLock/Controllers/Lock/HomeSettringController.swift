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
        case asset = 0
        case lockSetting = 10
        case lockInfo = 20
    }
    
    @IBOutlet weak var assetValueLabel: UILabel!
    @IBOutlet weak var lockValueLabel: UILabel!
    
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
        } else {
            assetValueLabel.text = "未绑定资产"
        }
        
        if LSLUser.current().scene?.roleType != .some(.superAdmin) {
            assetValueLabel.text = "仅超级管理员可查看"
            lockValueLabel.text = "仅超级管理员可查看"
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
        case .asset:
            
            if LSLUser.current().scene?.ladderAssetHouseId.isNilOrEmpty ?? false {
                let pendingVC: AssetPendingListController = ViewLoader.Storyboard.controller(from: "Home")
                navigationController?.pushViewController(pendingVC, animated: true)
            } else {
                let editAssetVC: BindingOrEditAssetViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
                
                if let asset = try? currentAsset.value() {
                    editAssetVC.asset = asset
                }
                navigationController?.pushViewController(editAssetVC, animated: true)
            }
            
        case .lockSetting:
            
            let lockSettingVC: LockSettingController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockSettingVC, animated: true)
            
        case .lockInfo:
            
            let lockInfoVC: LockInfoController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(lockInfoVC, animated: true)
            
        }
    }
}
