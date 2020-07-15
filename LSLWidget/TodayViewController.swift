//
//  TodayViewController.swift
//  LSLWidget
//
//  Created by mugua on 2020/1/2.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import NotificationCenter
import NSObject_Rx
import RxDataSources

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var sceneNameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var tvDatasource: RxTableViewSectionedReloadDataSource<TodayViewModel.Section>!
    var vm: TodayViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        setupUI()
        bind()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "WidgetUnlockRecordCell", bundle: nil), forCellReuseIdentifier: "WidgetUnlockRecordCell")
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.indicatorView.stopAnimating()
        }
    }
    
    func bind() {
        let shareDefault = UserDefaults(suiteName: ShareUserDefaultsKey.groupId.rawValue)
        let sceneStr = shareDefault?.string(forKey: ShareUserDefaultsKey.scene.rawValue)
        guard let lockId = SceneListModel.deserialize(from: sceneStr)?.ladderLockId else {
            indicatorView.stopAnimating()
            return
        }
        
        vm = TodayViewModel(lockId: lockId)
        
        vm.sceneName.bind(to: sceneNameLabel.rx.text).disposed(by: rx.disposeBag)
        vm.currentPower.bind(to: powerLabel.rx.text).disposed(by: rx.disposeBag)
        vm.requestExecuting.bind(to: indicatorView.rx.isAnimating).disposed(by: rx.disposeBag)
        
        tvDatasource = RxTableViewSectionedReloadDataSource(configureCell: { (ds, tv, ip, item) -> WidgetUnlockRecordCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "WidgetUnlockRecordCell", for: ip) as! WidgetUnlockRecordCell
            cell.nameLabel.text = item.userName
            cell.timeLabel.text = item.openTime
            cell.unlockWayLabel.text = item.openType
            
            return cell
        })
        
        vm.dataSource.bind(to: tableView.rx.items(dataSource: tvDatasource)).disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] (_) in
            if let hostAppUrl = URL(string: "LightSmartLock://") {
                self?.extensionContext?.open(hostAppUrl, completionHandler: nil)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize
        case .expanded:
            preferredContentSize = CGSize(width: 0.0, height: 50 * CGFloat(5) + 10)
        @unknown default:
            fatalError()
        }
    }
    
}
