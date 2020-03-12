//
//  FingerManageController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import MJRefresh
import PKHUD

class FingerManageCell: UITableViewCell {
    
    @IBOutlet weak var fingerLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(_ data: FingerModel) {
        fingerLabel.text = data.mark
    }
}

class FingerManageController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let vm = FingerManageViewModel()
    var dataSource: [FingerModel] = []
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "指纹管理"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
        setupTableviewRefresh()
        setupNavigationRightItem()
        bind()
    }
    
    func bind() {
        vm.refreshStatus.subscribe(onNext: {[weak self] (status) in
            switch status {
            case .endFooterRefresh:
                self?.tableView.mj_footer?.endRefreshing()
            case .endHeaderRefresh:
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.resetNoMoreData()
            case .noMoreData:
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            case .none:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
                    self?.tableView.mj_header?.beginRefreshing()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        vm.list.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "添加指纹", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white).rx.tap.subscribe(onNext: {[weak self] (_) in
            let addFingerVC: AddFingerController = ViewLoader.Storyboard.controller(from: "InitialLock")
            self?.navigationController?.pushViewController(addFingerVC, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        tableView.emptyDataSetSource = self
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
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FingerManageCell", for: indexPath) as! FingerManageCell
        
        let data = self.dataSource[indexPath.row]
        cell.bind(data)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataSource[indexPath.row]
        let fingerDetailVC: FingerDetailController = ViewLoader.Storyboard.controller(from: "Home")
        fingerDetailVC.fingerModel = data
        navigationController?.pushViewController(fingerDetailVC, animated: true)
    }
}
