//
//  MessageCenterController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import ReactorKit
import RxSwift
import MJRefresh
import SwiftDate
import Action
import RxDataSources

class MessageCenterCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func bind(_ data: CenterMessageModel) {
        titleLabel.text = data.title
        content.text = data.message
        if let time = data.smsCreatetime?.toDate()?.toString(.custom("MM / dd  HH:mm")) {
            timeLabel.text = time
        }
    }
    
    func setupUI() {
        
        [ignoreButton, agreeButton].forEach { (btn) in
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = ColorClassification.textPlaceholder.value.cgColor
            btn?.layer.cornerRadius = 3
        }
        // 这期不做
        buttonContainer.removeArrangedSubview(ignoreButton)
        buttonContainer.removeArrangedSubview(agreeButton)
        ignoreButton.removeFromSuperview()
        agreeButton.removeFromSuperview()
        layoutIfNeeded()
    }
}

class MessageCenterController: UITableViewController, StoryboardView, NavigationSettingStyle {
    
    typealias Reactor = MessageCenterReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    var dataSource: [CenterMessageModel] = []
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    private lazy var segment: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["资产消息", "门锁消息"])
        seg.selectedSegmentIndex = 0
        return seg
    }()
    private var filterButton: UIButton!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "消息中心"
        setupUI()
        setupNavigationItem()
        
        if let assetId = LSLUser.current().scene?.ladderAssetHouseId {
            self.reactor = Reactor(assetId: assetId)
        } else {
            HUD.flash(.label("发生未知错误, 无法获取资产ID"), delay: 2)
        }
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.emptyDataSetSource = self
    }
    
    func setupNavigationItem() {
        
        self.navigationItem.titleView = self.segment
    }
    
    func bind(reactor: MessageCenterReactor) {
        
        let refreshBegin = BehaviorRelay<Reactor.Action>(value: .refreshBegin(nil))
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            refreshBegin.accept(.refreshBegin(1))
        })
        refreshBegin.bind(to: reactor.action).disposed(by: rx.disposeBag)
        
        let pullToLoad = BehaviorRelay<Reactor.Action>(value: .loadMoreBegin(nil))
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            
            pullToLoad.accept(.loadMoreBegin(1))
            
        })
        footer.setTitle("", for: .idle)
        tableView.mj_footer = footer
        pullToLoad.bind(to: reactor.action).disposed(by: rx.disposeBag)
        
        segment.rx.value.map {
            Reactor.Action.changeMessageType($0)
        }
        .bind(to: reactor.action)
        .disposed(by: rx.disposeBag)
        
        reactor.state.map { $0.isNoMoreData }
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (noMore) in
                if noMore {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.pageIndex }.distinctUntilChanged().subscribe(onNext: { (index) in
            print("当前页码\(index)")
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.isFinished }.subscribe(onNext: {[weak self] (_) in
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.messageList }.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.messageType }
            .distinctUntilChanged()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (_) in
                self?.tableView.mj_footer?.resetNoMoreData()
            })
            .disposed(by: disposeBag)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCenterCell", for: indexPath) as! MessageCenterCell
        
        cell.bind(dataSource[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
