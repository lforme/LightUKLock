//
//  MyViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import Kingfisher
import MJRefresh

class MyViewController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.primary.value
    }
    
    var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        return tv
    }()
    
    let vm = MyViewModel()
    
    var dataSource: [SceneListModel] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = view.frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        setupTableviewRefresh()
        bind()
        observerSceneChanged()
        
    }
    
    func observerSceneChanged() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            
            switch refreshType {
            case .deleteScene, .updateScene:
                self?.tableView.mj_header?.beginRefreshing()
            default: break
            }
            
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .addLock, .deleteLock:
                self?.tableView.mj_header?.beginRefreshing()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        vm.requestFinished.subscribe(onNext: {[weak self] (finished) in
            if finished {
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        vm.sceneList.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupTableviewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.vm.refresh()
        })
        tableView.mj_header?.beginRefreshing()
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.viewBackground.value
        self.tableView.backgroundColor = ColorClassification.tableViewBackground.value
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "MyInfoHeader", bundle: nil), forCellReuseIdentifier: "MyInfoHeader")
        self.tableView.register(UINib(nibName: "MyListCell", bundle: nil), forCellReuseIdentifier: "MyListCell")
        self.tableView.sectionHeaderHeight = 300
        self.tableView.rowHeight = 136
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(tableView)
    }
    
    func setupNavigation() {
        
        self.interactiveNavigationBarHidden = true
        AppDelegate.changeStatusBarStyle(.lightContent)
    }
    
    @objc func gotoMySettingVC() {
        let settingVC: MySettingViewController = ViewLoader.Storyboard.controller(from: "My")
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc func gotoSelectedLockVC() {
        let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
        selectVC.kind = .newAdd
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
}

extension MyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyListCell", for: indexPath) as! MyListCell
        let data = dataSource[indexPath.row]
        cell.bind(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "MyInfoHeader") as! MyInfoHeader
        header.settingButton.addTarget(self, action: #selector(self.gotoMySettingVC), for: .touchUpInside)
        header.addButton.addTarget(self, action: #selector(self.gotoSelectedLockVC), for: .touchUpInside)
        
        let shareInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
        shareInfo.map { $0?.nickname }.bind(to: header.nick.rx.text).disposed(by: header.disposeBag)
        shareInfo.map { $0?.phone }.bind(to: header.phone.rx.text).disposed(by: header.disposeBag)
        shareInfo.map { $0?.avatar }.subscribe(onNext: { (urlString) in
            header.avatar?.setUrl(urlString)
        }).disposed(by: header.disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scene = dataSource[indexPath.row]
        LSLUser.current().scene = scene
        let lockVC: HomeViewController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(lockVC, animated: true)
        if let visiableRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visiableRows, with: .automatic)
        }
    }
}
