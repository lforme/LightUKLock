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
    let vm = TodayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        setupUI()
        bind()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "WidgetUnlockRecordCell", bundle: nil), forCellReuseIdentifier: "WidgetUnlockRecordCell")
        tableView.rowHeight = 76
        tableView.separatorStyle = .none
    }
    
    func bind() {
        vm.sceneName.bind(to: sceneNameLabel.rx.text).disposed(by: rx.disposeBag)
        vm.currentPower.bind(to: powerLabel.rx.text).disposed(by: rx.disposeBag)
        vm.requestExecuting.bind(to: indicatorView.rx.isAnimating).disposed(by: rx.disposeBag)
        
        tvDatasource = RxTableViewSectionedReloadDataSource(configureCell: { (ds, tv, ip, item) -> WidgetUnlockRecordCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "WidgetUnlockRecordCell", for: ip) as! WidgetUnlockRecordCell
            cell.nameLabel.text = item.customerNickName
            cell.timeLabel.text = item.UnlockTime
            cell.unlockWayLabel.text = item.KeyType.description
            switch ip.section {
            case 0:
                cell.bgView.backgroundColor = #colorLiteral(red: 0.9534692168, green: 0.4842274189, blue: 0.1130582169, alpha: 1)
            case 1:
                cell.bgView.backgroundColor = #colorLiteral(red: 0.009328175336, green: 0.5046331882, blue: 1, alpha: 1)
            case 2:
                cell.bgView.backgroundColor = #colorLiteral(red: 0.611283958, green: 0.1478919685, blue: 0.6898549199, alpha: 1)
            default: break
            }
            
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
            preferredContentSize = CGSize(width: 0.0, height: 70 * CGFloat(5))
        @unknown default:
            fatalError()
        }
    }
    
}
