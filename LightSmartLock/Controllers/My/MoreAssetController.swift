//
//  MoreAssetController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/24.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class MoreAssetController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var navigationRightButton: UIButton!
    var vm: MyViewModel!
    
    var dataSource: [SceneListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "更多资产"
        setupUI()
        setupNavigationRightItem()
        fetchData()
        bind()
    }
    
    func bind() {
        confirmButton.rx
            .tap
            .flatMapLatest({[weak self] (_) -> Observable<Bool> in
                guard let selectRows = self?.tableView.indexPathsForSelectedRows, selectRows.count != 0 else {
                    HUD.flash(.label("至少勾选一个资产"), delay: 2)
                    return .empty()
                }
                
                let selectedModels = selectRows.map { (ip) -> IsTopModel in
                    var isTopModel = IsTopModel()
                    isTopModel.isTop = true
                    isTopModel.id = self?.dataSource[ip.row].id
                    return isTopModel
                }
                
                var array = self?.dataSource.map({ (item) -> IsTopModel in
                    var isTopModel = IsTopModel()
                    isTopModel.isTop = false
                    isTopModel.id = item.id
                    return isTopModel
                }) ?? []
                
                for vaule in selectedModels {
                    if let b = array.filter({ $0.id == vaule.id }).first,
                        let removeIndex = array.firstIndex(where: { b.id == $0.id }) {
                        array.remove(at: removeIndex)
                    }
                }
                
                array += selectedModels
            
                return BusinessAPI.requestMapBool(.topAsset(list: array))
                
            }).subscribe(onNext: {[weak self] (success) in
                if success {
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.updateScene)
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.navigationRightButton.isSelected = false
                self?.tableView.setEditing(false, animated: true)
                }, onError: {[weak self] (error) in
                    self?.navigationRightButton.isSelected = false
                    self?.tableView.setEditing(false, animated: true)
                    PKHUD.sharedHUD.rx.showError(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.register(UINib(nibName: "MoreAssetCell", bundle: nil), forCellReuseIdentifier: "MoreAssetCell")
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func setupNavigationRightItem() {
        navigationRightButton = createdRightNavigationItem(title: "编辑", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white)
        navigationRightButton.addTarget(self, action: #selector(editItemTap(_:)), for: .touchUpInside)
        navigationRightButton.setTitle("取消", for: .selected)
        navigationRightButton.setTitle("编辑", for: .normal)
    }
    
    @objc func editItemTap(_ sender: UIButton) {
        tableView.allowsMultipleSelectionDuringEditing = !tableView.isEditing
        tableView.setEditing(!tableView.isEditing, animated: true)
        sender.isSelected = !sender.isSelected
    }
    
    func fetchData() {
        
        BusinessAPI.requestMapJSONArray(.getHouses, classType: SceneListModel.self, useCache: true)
            .map { $0.compactMap { $0 } }
            .subscribe(onNext: {[weak self] (list) in
                
                self?.dataSource = list
                self?.tableView.reloadData()
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            })
            .disposed(by: self.rx.disposeBag)
    }
}


extension MoreAssetController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreAssetCell", for: indexPath) as! MoreAssetCell
        let data = dataSource[indexPath.row]
        if data.ladderLockId.isNilOrEmpty {
            cell.subName.text = "未绑定门锁"
            cell.bindButton.isHidden = false
        } else {
            cell.subName.text = data.lockType
            cell.bindButton.isHidden = true
        }
        
        if data.ladderAssetHouseId.isNilOrEmpty {
            cell.name.text = "未绑定资产"
        } else {
            cell.name.text = data.buildingName
        }
        cell.bindButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            LSLUser.current().scene = self?.dataSource[indexPath.row]
            self?.gotoSelectedLockVC()
        }).disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func gotoSelectedLockVC() {
        
        vm.configuredList.subscribe(onNext: {[weak self] (bindLockList) in
            
            if bindLockList.count != 0 {
                let bindLockListVC: BindLockListController = ViewLoader.Storyboard.controller(from: "InitialLock")
                bindLockListVC.dataSource = bindLockList
                self?.navigationController?.pushViewController(bindLockListVC, animated: true)
            } else {
                let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
                selectVC.kind = .newAdd
                self?.navigationController?.pushViewController(selectVC, animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
}

extension MoreAssetController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
