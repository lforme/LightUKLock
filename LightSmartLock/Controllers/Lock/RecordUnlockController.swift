//
//  RecordUnlockController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import PKHUD
import MJRefresh
import RxDataSources
import Then

class RecordUnlockController: UIViewController, View {
    
    typealias Reactor = RecordUnlockReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    fileprivate var userCode: String!
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain).then {
        $0.tableFooterView = UIView(frame: .zero)
        $0.register(UINib(nibName: "UnlockRecordCell", bundle: nil), forCellReuseIdentifier: "UnlockRecordCell")
        $0.rowHeight = 64.0
        $0.backgroundColor = ColorClassification.tableViewBackground.value
    }
    
    convenience init(userCode: String) {
        self.init()
        self.userCode = userCode
    }
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, UnlockRecordModel>>!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "解锁记录"
        setupUI()
        self.reactor = Reactor(userCode: userCode)
    }
    
    func setupUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
    }
    
    
    func bind(reactor: RecordUnlockReactor) {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            Observable.just(Reactor.Action.refreshChange(1)).bind(to: reactor.action).disposed(by: this.disposeBag)
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            Observable.just(Reactor.Action.loadMore(1)).bind(to: reactor.action).disposed(by: this.disposeBag)
        })
        
        reactor.state.map { $0.loadMoreFinished }.delay(1, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (noMore) in
            if noMore {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.networkError }.subscribe(onNext: { (e) in
            PKHUD.sharedHUD.rx.showAppError(e)
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.pageIndex }.distinctUntilChanged().subscribe(onNext: { (index) in
            print("当前页码\(index)")
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.requestFinished }.subscribe(onNext: {[weak self] (_) in
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
        }).disposed(by: disposeBag)
        
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UnlockRecordModel>>(configureCell: { (ds, tv, ip, item) -> UnlockRecordCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "UnlockRecordCell", for: ip) as! UnlockRecordCell
            cell.contentView.backgroundColor = ColorClassification.viewBackground.value
            cell.bind(item)
            return cell
        })
        
        reactor.state.map { $0.recordList }.map { [SectionModel(model: "解锁记录", items: $0)] }.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
    }
}
