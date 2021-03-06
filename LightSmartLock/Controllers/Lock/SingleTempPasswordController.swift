//
//  SingleTempPasswordController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import MJRefresh
import SwiftDate

class SingleTempPasswordCell: UITableViewCell {
    
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var sendTime: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(_ data: TempPasswordListModel) {
        if let mark = data.remark {
            markLabel.text = "备注: \(mark)"
        }
        
        if let send = data.startTime?.toDate() {
            if send.isToday {
                sendTime.text = "发送时间:  今天\(send.toString(.custom("HH点mm分")))"
            } else {
                sendTime.text = "发送时间:  \(send.toString(.custom("MM月dd日 HH点mm分")))"
            }
        }
        
        if let end = data.endTime?.toDate() {
            availableLabel.text = end.toString(.custom("MM月dd日")) + "有效"
        }
        
        status.text = data.status
    }
}

class SingleTempPasswordController: UITableViewController, NavigationSettingStyle {
    
    let shareButton = UIButton(type: .custom).then {
        $0.setImage(UIImage.init(named: "password_share"), for: UIControl.State())
        $0.setCircular(radius: $0.bounds.height / 2)
        $0.frame = CGRect(x: UIScreen.main.bounds.width - 72, y: UIScreen.main.bounds.height - 182, width: 56, height: 56)
    }
    
    var dataSource: [TempPasswordListModel] = []
    var vm: TempPasswordViewModel!
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "临时密码"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
        bind()
        setupTableviewRefresh()
        observerNotification()
    }
    
    func observerNotification() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .tempPassword:
                self?.vm.refresh()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        self.vm = TempPasswordViewModel(type: .single)
        
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
        
        shareButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            let shareVC: SharePasswordSignleController = ViewLoader.Storyboard.controller(from: "Home")
            self?.navigationController?.pushViewController(shareVC, animated: true)
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
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.rowHeight = 128
        tableView.addSubview(shareButton)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleTempPasswordCell", for: indexPath) as! SingleTempPasswordCell
        let data = dataSource[indexPath.row]
        cell.bind(data)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataSource[indexPath.row]
        vm.showLogView(data)
    }
}
