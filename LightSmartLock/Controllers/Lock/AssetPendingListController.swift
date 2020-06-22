//
//  AssetPendingListController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/22.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift
import Action

class AssetPendingListController: UIViewController, NavigationSettingStyle {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var dataSource: [AssetPendingModel] = []
    
    var backgroundColor: UIColor? {
        ColorClassification.navigationBackground.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定资产"
        setupUI()
        setupNavigationRightItem()
        fetchData()
        bind()
    }
    
    func bind() {
        let action = Action<Void, Bool> {[weak self] (_) -> Observable<Bool> in
            guard let this = self else {
                return .empty()
            }
            
            guard let lockId = LSLUser.current().scene?.ladderLockId else {
                return .empty()
            }
            
            let assetId = this.dataSource.filter { ($0.isBind ?? false) }.first?.ladderAssetHouseId
            
            return BusinessAPI.requestMapBool(.assetBindLock(lockId: lockId, assetId: assetId))
        }
        
        confirmButton.rx.bind(to: action, input: ())
        
        action.errors
            .subscribe(onNext: { (actionError) in
                PKHUD.sharedHUD.rx.showActionError(actionError)
            })
            .disposed(by: rx.disposeBag)
        
        action.elements
            .subscribe(onNext: {[weak self] (success) in
                if success {
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.updateScene)
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = 54
        tableView.register(UINib(nibName: "AssetPendingListCell", bundle: nil), forCellReuseIdentifier: "AssetPendingListCell")
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "新建资产", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white)
            .rx
            .tap
            .subscribe(onNext: {[weak self] (_) in
                let editAssetVC: BindingOrEditAssetViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
                self?.navigationController?.pushViewController(editAssetVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func fetchData() {
        if let lockId = LSLUser.current().scene?.ladderLockId {
            BusinessAPI.requestMapJSONArray(.findAssetByLockId(id: lockId), classType: AssetPendingModel.self)
                .map { $0.compactMap { $0 } }
                .subscribe(onNext: {[weak self] (list) in
                    self?.dataSource = list
                    self?.tableView.reloadData()
                    }, onError: { (error) in
                        PKHUD.sharedHUD.rx.showError(error)
                })
                .disposed(by: rx.disposeBag)
        } else {
            BusinessAPI.requestMapJSONArray(.findAssetNotBind, classType: AssetPendingModel.self)
                .map { $0.compactMap { $0 } }
                .subscribe(onNext: {[weak self] (list) in
                    self?.dataSource = list
                    self?.tableView.reloadData()
                    }, onError: { (error) in
                        PKHUD.sharedHUD.rx.showError(error)
                })
                .disposed(by: rx.disposeBag)
        }
    }
}

extension AssetPendingListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetPendingListCell", for: indexPath) as! AssetPendingListCell
        let data = dataSource[indexPath.row]
        cell.bind(data)
        return cell
    }
}

extension AssetPendingListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataSource[indexPath.row]
        model.isBind = !(model.isBind ?? false)
        
        dataSource.filter { $0 != model }.forEach { $0.isBind = false }
        
        tableView.reloadData()
    }
}
