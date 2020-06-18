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
    
    deinit {
          print("deinit \(self)")
      }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "管家列表"
        setupUI()
        setupNavigationRightItem()
        setupTableViewRefresh()
        setupObserver()
        bind()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = false
        clearsSelectionOnViewWillAppear = true
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "添加", font: nil, image: nil, rightEdge: 4, color: .white)
            .rx
            .tap
            .subscribe(onNext: {[weak self] (_) in
                let addStewardVC: AddOrEditController = ViewLoader.Storyboard.controller(from: "Home")
                self?.navigationController?.pushViewController(addStewardVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupObserver() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .steward:
                self?.obIndex.accept(1)
            default: break
            }
        }).disposed(by: rx.disposeBag)
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
            
            if list.count == 0 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
            if self?.obIndex.value == 1 {
                self?.dataSource = list
                self?.tableView.mj_footer?.resetNoMoreData()
            } else {
                self?.dataSource += list
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
            guard let id = dataSource[indexPath.row].id else {
                return
            }
            self.deleteSteward(by: id)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let steward = dataSource[indexPath.row]
        let editStewardVC: AddOrEditController = ViewLoader.Storyboard.controller(from: "Home")
        editStewardVC.kind = .edit
        editStewardVC.steward = steward
        navigationController?.pushViewController(editStewardVC, animated: true)
    }
}


extension HouseKeeperListController {
    
    func deleteSteward(by id: String) {
        
        BusinessAPI.requestMapBool(.deleteSteward(id: id)).subscribe(onNext: {[weak self] (success) in
            if success {
                guard let removeIndex = self?.dataSource.firstIndex(where: { $0.id ?? "" == id }) else { return }
                self?.dataSource.remove(at: removeIndex)
                self?.tableView.beginUpdates()
                self?.tableView.deleteRows(at: [IndexPath(row: removeIndex, section: 0)], with: .automatic)
                self?.tableView.endUpdates()
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.steward)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
}
