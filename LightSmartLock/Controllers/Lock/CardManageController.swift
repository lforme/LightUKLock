//
//  CardManageController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import MJRefresh
import PKHUD

class CardManageCell: UITableViewCell {
    
    @IBOutlet weak var cardName: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CardManageController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let vm = CardManageViewModel()
    var dataSource: [OpenLockInfoModel.Card] = []
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        self.title = "门卡管理"
        
        setupUI()
        bind()
        setupNavigationRightItem()
        setupTableviewRefresh()
        observerNotification()
    }
    
    func observerNotification() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .addCard:
                self?.vm.refresh()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        
        vm.list.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupTableviewRefresh() {
        vm.refresh()
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "添加门卡", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white).rx.tap.subscribe(onNext: {[weak self] (_) in
            let addCardVC: AddCardController = ViewLoader.Storyboard.controller(from: "InitialLock")
            self?.navigationController?.pushViewController(addCardVC, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        tableView.emptyDataSetSource = self
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardManageCell", for: indexPath) as! CardManageCell
        
        cell.cardName.text = dataSource[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataSource[indexPath.row]
        let cardDetailVC: CardDetailController = ViewLoader.Storyboard.controller(from: "Home")
        cardDetailVC.keyNumber = data.keyNum
        cardDetailVC.keyId = data.id
        cardDetailVC.cardName = data.name
        navigationController?.pushViewController(cardDetailVC, animated: true)
    }
}
