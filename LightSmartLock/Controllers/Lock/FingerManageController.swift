//
//  FingerManageController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD

class FingerManageCell: UITableViewCell {
    
    @IBOutlet weak var fingerLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(_ data: OpenLockInfoModel.Finger) {
        fingerLabel.text = data.name
    }
}

class FingerManageController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    let vm = FingerManageViewModel()
    var dataSource: [OpenLockInfoModel.Finger] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.refresh()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "指纹管理"
        self.clearsSelectionOnViewWillAppear = true
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func bind() {
        vm.list.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "添加指纹", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white).rx.tap.subscribe(onNext: {[weak self] (_) in
            let addFingerVC: AddFingerController = ViewLoader.Storyboard.controller(from: "InitialLock")
            self?.navigationController?.pushViewController(addFingerVC, animated: true)
            
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
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FingerManageCell", for: indexPath) as! FingerManageCell
        
        let data = self.dataSource[indexPath.row]
        cell.bind(data)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataSource[indexPath.row]
        let fingerDetailVC: FingerDetailController = ViewLoader.Storyboard.controller(from: "Home")
        fingerDetailVC.fingerModel = data
        navigationController?.pushViewController(fingerDetailVC, animated: true)
    }
}
