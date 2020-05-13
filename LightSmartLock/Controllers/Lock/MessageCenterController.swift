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
        content.text = data.content
        if let time = data.createDate?.toDate()?.toString(.custom("MM / dd  HH:mm")) {
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

class MessageCenterController: UITableViewController, StoryboardView {
    
    typealias Reactor = MessageCenterReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    var dataSource: [CenterMessageModel] = []
    
    private var filterButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.mj_header?.beginRefreshing()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "消息中心"
        setupUI()
        setupRightNavigationItem()
        
        self.reactor = Reactor()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.emptyDataSetSource = self
    }
    
    func setupRightNavigationItem() {
        self.filterButton = createdRightNavigationItem(title: nil, image: UIImage(named: "message_filter"))
    }
    
    func bind(reactor: MessageCenterReactor) {
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            
            Observable.just(Reactor.Action.refreshBegin).bind(to: reactor.action).disposed(by: this.disposeBag)
        })
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            guard let this = self else { return }
            Observable.just(Reactor.Action.loadMoreBegin).delaySubscription(.seconds(1), scheduler: MainScheduler.instance).bind(to: reactor.action).disposed(by: this.disposeBag)
        })
        
        footer.setTitle("", for: .idle)
        self.tableView.mj_footer = footer
        
        self.filterButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Reactor.Action> in
            guard let this = self else { return .empty() }
            return Observable<Reactor.Action>.create { (observer) -> Disposable in
                this.showActionSheet(title: "选择消息类型", message: nil, buttonTitles: ["门锁消息", "资产消息"], highlightedButtonIndex: 0) { (index) in
                    observer.onNext(Reactor.Action.changeMessageType(index))
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        reactor.state.map { $0.IsNomoreData }.delay(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (noMore) in
            if noMore {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.pageIndex }.distinctUntilChanged().subscribe(onNext: { (index) in
            print("当前页码\(index)")
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.requestFinish }.subscribe(onNext: {[weak self] (_) in
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
        }).disposed(by: disposeBag)
        
        reactor.state.map { $0.messageList }.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: disposeBag)
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
