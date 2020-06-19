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
import BetterSegmentedControl

class RecordUnlockController: UIViewController, View {
    
    typealias Reactor = RecordUnlockReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    fileprivate var lockId: String!
    fileprivate var userId: String!
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain).then {
        $0.tableFooterView = UIView(frame: .zero)
        $0.register(UINib(nibName: "UnlockRecordCell", bundle: nil), forCellReuseIdentifier: "UnlockRecordCell")
        $0.rowHeight = 72.0
        $0.backgroundColor = ColorClassification.tableViewBackground.value
    }
    
    let control = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["今日", "昨日", "全部"],
                                        normalFont: UIFont(name: "HelveticaNeue-Light", size: 14.0)!,
                                        normalTextColor: .white,
                                        selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!,
                                        selectedTextColor: ColorClassification.primary.value),
        index: 0,
        options: [.backgroundColor(ColorClassification.primary.value),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(24),
                  .indicatorViewInset(4)])
    
    
    convenience init(lockId: String, userId: String) {
        self.init()
        self.userId = userId
        self.lockId = lockId
    }
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, UnlockRecordModel>>!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.mj_header?.beginRefreshing()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "解锁记录"
        setupUI()
        self.reactor = Reactor(lockId: lockId, userId: userId)
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        self.view.addSubview(tableView)
        self.view.addSubview(control)
        
        control.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view.snp.top).offset(20)
            maker.left.equalTo(self.view.snp.left).offset(20)
            maker.height.equalTo(48)
            maker.width.equalTo(180)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(self.control.snp.bottom).offset(16)
        }
        
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
    }
    
    
    func bind(reactor: RecordUnlockReactor) {
        
        control.rx.controlEvent(.valueChanged).map {[unowned self] (_) -> Reactor.Action in
            return Reactor.Action.filter(self.control.index + 1)
        }
        .bind(to: reactor.action)
        .disposed(by: rx.disposeBag)
        
        let pullToRefreshAction = BehaviorRelay<Reactor.Action>(value: Reactor.Action.pullToRefresh(nil))
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            pullToRefreshAction.accept(Reactor.Action.pullToRefresh(1))
        })
        
        pullToRefreshAction.asObservable()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        let pullUpLoadAction = BehaviorRelay<Reactor.Action>(value: Reactor.Action.pullUpLoading(nil))
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            pullUpLoadAction.accept(Reactor.Action.pullUpLoading(1))
        })
        footer.setTitle("", for: .idle)
        tableView.mj_footer = footer
        
        pullUpLoadAction.asObservable()
            .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor
            .state
            .map { $0.requestFinished }
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (end) in
                if end {
                    self?.tableView.mj_header?.endRefreshing()
                    self?.tableView.mj_footer?.endRefreshing()
                }
            }).disposed(by: disposeBag)
        
        reactor
            .state
            .map { $0.noMoreData }
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (noMore) in
                if noMore {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }).disposed(by: disposeBag)
        
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UnlockRecordModel>>(configureCell: {[unowned self] (ds, tv, ip, item) -> UnlockRecordCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "UnlockRecordCell", for: ip) as! UnlockRecordCell
            cell.contentView.backgroundColor = ColorClassification.viewBackground.value
            cell.bind(item, filterType: self.control.index + 1)
            
            if ip.row == 0 {
                cell.topLine.isHidden = true
            } else {
                cell.topLine.isHidden = false
            }
            
            return cell
        })
        
        reactor
            .state
            .map { $0.dataList }.map { [SectionModel(model: "解锁记录", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
