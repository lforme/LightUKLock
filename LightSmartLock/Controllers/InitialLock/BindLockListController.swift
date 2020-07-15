//
//  BindLockListController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/4.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import PKHUD

class BindLockListController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    lazy var dataSource = [BindLockListModel]()
    let selectedModel = BehaviorRelay<BindLockListModel?>(value: nil)
    
    var tvDatasource: RxTableViewSectionedReloadDataSource<SectionModel<String, BindLockListModel>>!
    
    deinit {
        print("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "请选择已配置的门锁"
        setupUI()
        bind()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 72
        tableView.register(UINib(nibName: "BindLockListCell", bundle: nil), forCellReuseIdentifier: "BindLockListCell")
    }
    
    func bind() {
        tvDatasource = RxTableViewSectionedReloadDataSource<SectionModel<String, BindLockListModel>>.init(configureCell: { (ds, tv, ip, item) -> BindLockListCell in
            
            let cell = tv.dequeueReusableCell(withIdentifier: "BindLockListCell", for: ip) as! BindLockListCell
            let snCode = item.snCode ?? "-"
            cell.snLabel.text = "SN码 \(snCode)"
            cell.addressLabel.text = item.address
            return cell
        })
        
        Observable.just(dataSource)
            .map { [SectionModel(model: "选择门锁绑定", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: tvDatasource))
            .disposed(by: rx.disposeBag)
        
        
        otherButton.rx
            .tap
            .subscribe(onNext: {[weak self] (_) in
                let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
                selectVC.kind = .newAdd
                self?.navigationController?.pushViewController(selectVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(BindLockListModel.self)
            .bind(to: selectedModel)
            .disposed(by: rx.disposeBag)
        
        nextButton.rx
            .tap
            .flatMapLatest {[weak self] (_) -> Observable<Bool> in
                guard let assetId = LSLUser.current().scene?.ladderAssetHouseId, let snCode = self?.selectedModel.value?.snCode else {
                    
                    HUD.flash(.label("请选择要绑定门锁"), delay: 2)
                    return .empty()
                }
                
                return BusinessAPI.requestMapBool(.snBindLock(assetId: assetId, snCode: snCode))
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.updateScene)
                self?.navigationController?.popToRootViewController(animated: true)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        })
            .disposed(by: rx.disposeBag)
        
    }
}
