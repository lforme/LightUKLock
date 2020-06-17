//
//  HouseKeeperListController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import MJRefresh
import PKHUD
import RxCocoa
import RxSwift

class HouseKeeperListCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var company: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class HouseKeeperListController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let obIndex = BehaviorRelay<Int>(value: 1)
    var dataSource = [HouseKeeperModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "管家列表"
        setupUI()
        setupTableViewRefresh()
        bind()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = false
    }
    
    func setupTableViewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            this.obIndex.accept(1)
        })
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            this.obIndex.accept(this.obIndex.value + 1)
        })
        
        footer.setTitle("", for: .idle)
        self.tableView.mj_footer = footer
    }
    
    func bind() {
        obIndex.flatMapLatest {
            BusinessAPI.requestMapJSONArray(.stewardList(pageIndex: $0, pageSize: 15), classType: HouseKeeperModel.self, useCache: true, isPaginating: true).map { $0.compactMap { $0 } }
            
        }.subscribe(onNext: {[weak self] (list) in
            self?.tableView.mj_footer?.endRefreshing()
            self?.tableView.mj_header?.endRefreshing()
            if self?.obIndex.value == 1 {
                self?.dataSource = list
                self?.tableView.mj_footer?.resetNoMoreData()
            } else {
                self?.dataSource += list
            }
            if list.count == 0 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self?.tableView.reloadData()
            }, onError: {[weak self] (error) in
                PKHUD.sharedHUD.rx.showError(error)
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.endRefreshing()
        }).disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HouseKeeperListCell", for: indexPath) as! HouseKeeperListCell
        
        let data = dataSource[indexPath.row]
        cell.name.text = data.username
        cell.phone.text = data.phone
        cell.company.text = data.company
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}
