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
        return ColorClassification.tableViewBackground.value
    }
    
    @IBOutlet weak var tableView: UITableView!
    let vm: MyViewModeling = MyViewModel()
    
    var dataSource: [SceneListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRightNavigationItem()
        observerTableViewDidScroll()
        setupTableviewRefresh()
        bind()
    }
    
    func bind() {
        vm.requestFinished.subscribe(onNext: {[weak self] (finished) in
            if finished {
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.endRefreshing()
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        vm.nomore.delay(0.5, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (nomore) in
            if nomore {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
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
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.vm.loadMore()
        })
        footer.setTitle("", for: .idle)
        tableView.mj_footer = footer
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            self?.tableView.mj_header?.beginRefreshing()
        }

    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.viewBackground.value
        self.tableView.backgroundColor = ColorClassification.tableViewBackground.value
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "MyInfoHeader", bundle: nil), forCellReuseIdentifier: "MyInfoHeader")
        self.tableView.register(UINib(nibName: "MyListCell", bundle: nil), forCellReuseIdentifier: "MyListCell")
        self.tableView.sectionHeaderHeight = 160
        self.tableView.rowHeight = 136
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupRightNavigationItem() {
        let fix = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fix.width = 8
        let fixTwo = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixTwo.width = 16
        
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(UIImage(named: "my_setting"), for: UIControl.State())
        settingButton.sizeToFit()
        settingButton.addTarget(self, action: #selector(self.gotoMySettingVC), for: .touchUpInside)
        let settingItem = UIBarButtonItem(customView: settingButton)
        
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "my_add"), for: UIControl.State())
        addButton.sizeToFit()
        
        let addItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItems = [fix, settingItem, fixTwo, addItem]
    }
    
    func observerTableViewDidScroll() {
        tableView.rx.didScroll.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            if this.tableView.contentOffset.y > 160 {
                this.navigationController?.navigationBar.topItem?.titleView?.isHidden = false
            } else {
                this.navigationController?.navigationBar.topItem?.titleView?.isHidden = true
            }
        }).disposed(by: rx.disposeBag)
    }
    
    @objc func gotoMySettingVC() {
        let settingVC: MySettingViewController = ViewLoader.Storyboard.controller(from: "My")
        self.navigationController?.pushViewController(settingVC, animated: true)
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
        let shareInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
    
        shareInfo.map { $0?.userName }.bind(to: header.nick.rx.text).disposed(by: header.disposeBag)
        shareInfo.map { $0?.phone }.bind(to: header.phone.rx.text).disposed(by: header.disposeBag)
        
        shareInfo.map { $0?.headPic }.subscribe(onNext: { (urlString) in
            guard let str = urlString else { return }
            let newString =  str.replacingOccurrences(of: "\\", with: "/")
            header.avatar?.kf.setImage(with: URL(string: newString))
        }).disposed(by: header.disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scene = dataSource[indexPath.row]
        LSLUser.current().scene = scene
    }
}
