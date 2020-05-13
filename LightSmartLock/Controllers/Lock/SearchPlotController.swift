//
//  SearchPlotController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Action
import PKHUD
import MJRefresh

class SearchPlotController: UIViewController {
    
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, GoudaMapItemModel>>!
    private let vm = SearchPlotViewModel()
    private var didSelected: ((GoudaMapItemModel) -> Void)?
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "小区搜索"
        setupUI()
        bind()
    }
    
    func setupUI() {
        inputContainer.setCircular(radius: 7)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 90
        tableView.register(UINib(nibName: "SearchPlotCell", bundle: nil), forCellReuseIdentifier: "SearchPlotCell")
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search
    }
    
    func bind() {
        searchTextField.rx.text.orEmpty.changed.throttle(.seconds(2), scheduler: MainScheduler.instance).bind(to: vm.searchText).disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(GoudaMapItemModel.self))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (tuple) in
                self?.tableView.deselectRow(at: tuple.0, animated: true)
                self?.didSelected?(tuple.1)
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: rx.disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: {[unowned self] (ds, tv, ip, item) -> SearchPlotCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "SearchPlotCell", for: ip) as! SearchPlotCell
            cell.bind(item, keyword: self.vm.searchText.value)
            
            return cell
        })
        
        vm.sectionData.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.vm.loadMore()
        })
        
        footer.setTitle("", for: .idle)
        self.tableView.mj_footer = footer
        
        vm.refreshStatus.subscribe(onNext: {[weak self] status in
            switch status {
            case .endFooterRefresh:
                self?.tableView.mj_footer?.endRefreshing()
            case .noMoreData:
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func didSelectedItem(_ call: ((GoudaMapItemModel) -> Void)?) {
        self.didSelected = call
    }
}
