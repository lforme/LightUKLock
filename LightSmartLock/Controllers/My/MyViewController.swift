//
//  MyViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import Kingfisher
import MJRefresh
import Floaty

class MyViewController: UIViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    var isLargeTitle: Bool {
        return false
    }
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    lazy var floaty: Floaty = Floaty(frame: .zero)
    
    var clickCell: UITableViewCell?
    
    let vm = MyViewModel()
    
    var dataSource: [SceneListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        setupTableviewRefresh()
        bind()
        observerSceneChanged()
        verifyID()
    }
    
    func verifyID() {
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            LSLUser.current().isFirstLogin = false
        //        }
        
        if LSLUser.current().hasVerificationLock && !LSLUser.current().isFirstLogin {
            
            let verficationVC: VerficationIDController = ViewLoader.Storyboard.controller(from: "Login")
            verficationVC.modalPresentationStyle = .fullScreen
            self.present(verficationVC, animated: true, completion: nil)
        }
        LSLUser.current().isFirstLogin = false
    }
    
    @IBAction func moreAseetTap(_ sender: UIButton) {
        let moreAssetVC: MoreAssetController = ViewLoader.Storyboard.controller(from: "My")
        moreAssetVC.vm = self.vm
        self.navigationController?.pushViewController(moreAssetVC, animated: true)
    }
    
    func observerSceneChanged() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            
            switch refreshType {
            case .deleteScene, .updateScene:
                self?.tableView.mj_header?.beginRefreshing()
            default: break
            }
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .editLock:
                self?.tableView.mj_header?.beginRefreshing()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        vm.requestFinished.subscribe(onNext: {[weak self] (finished) in
            if finished {
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        vm.sceneList.subscribe(onNext: {[weak self] (list) in
            self?.dataSource = list
        }).disposed(by: rx.disposeBag)
        
        let shareInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
        shareInfo.map { $0?.nickname }.bind(to: nickNameLabel.rx.text).disposed(by: rx.disposeBag)
        shareInfo.map {
            guard var phone = $0?.phone else {
                return ""
            }
            let start = phone.index(phone.startIndex, offsetBy: 3)
            let end = phone.index(phone.startIndex, offsetBy: 3 + 4)
            phone.replaceSubrange(start..<end, with: "****")
            return phone
        }.bind(to: phoneLabel.rx.text).disposed(by: rx.disposeBag)
        shareInfo.map { $0?.avatar }.subscribe(onNext: {[weak self] (urlString) in
            self?.avatarView.setUrl(urlString)
        }).disposed(by: rx.disposeBag)
        
        let addAssetItem = FloatyItem()
        addAssetItem.title = "资产"
        addAssetItem.titleLabel.font = UIFont.systemFont(ofSize: 14)
        addAssetItem.titleColor = .white
        addAssetItem.iconImageView.image = UIImage(named: "my_add_asset")
        addAssetItem.imageSize = CGSize(width: 52, height: 52)
        floaty.addItem(item: addAssetItem)
        let addLockItem = FloatyItem()
        addLockItem.title = "门锁"
        addLockItem.titleLabel.font = UIFont.systemFont(ofSize: 14)
        addLockItem.titleColor = .white
        addLockItem.iconImageView.image = UIImage(named: "my_add_lock")
        addLockItem.imageSize = CGSize(width: 52, height: 52)
        floaty.addItem(item: addLockItem)
        
        addAssetItem.handler = {[weak self] _ in
            self?.gotoAssetVC()
        }
        
        addLockItem.handler = {[weak self] _ in
            self?.gotoSelectedLockVC()
        }
    }
    
    func setupTableviewRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.vm.refresh()
        })
        tableView.mj_header?.beginRefreshing()
    }
    
    func setupUI() {
        self.view.layer.contents = UIImage(named: "personal_center_bg")?.cgImage
        self.avatarView.setCircular(radius: avatarView.bounds.height / 2)
        
        let avatarGestureTap = UITapGestureRecognizer(target: self, action: #selector(gotoMySettingVC))
        self.avatarView.addGestureRecognizer(avatarGestureTap)
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "MyListCell", bundle: nil), forCellReuseIdentifier: "MyListCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(floaty)
        floaty.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view.snp.right).offset(-16)
            maker.bottom.equalTo(self.view.snp.bottom).offset(-48)
            maker.width.height.equalTo(48)
        }
        floaty.buttonColor = #colorLiteral(red: 1, green: 0.6639282703, blue: 0.245883733, alpha: 1)
        floaty.plusColor = .white
        floaty.openAnimationType = .slideUp
        floaty.itemSpace = 28
    }
    
    func setupNavigation() {
        
        self.interactiveNavigationBarHidden = true
        AppDelegate.changeStatusBarStyle(.lightContent)
    }
    
    @objc func gotoMySettingVC() {
        let settingVC: MySettingViewController = ViewLoader.Storyboard.controller(from: "My")
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func gotoAssetVC() {
        let editAssetVC: BindingOrEditAssetViewController = ViewLoader.Storyboard.controller(from: "AssetDetail")
        navigationController?.pushViewController(editAssetVC, animated: true)
    }
    
    func gotoSelectedLockVC() {
        
        vm.configuredList.subscribe(onNext: {[weak self] (bindLockList) in
            
            if bindLockList.count != 0 {
                let bindLockListVC: BindLockListController = ViewLoader.Storyboard.controller(from: "InitialLock")
                bindLockListVC.dataSource = bindLockList
                self?.navigationController?.pushViewController(bindLockListVC, animated: true)
            } else {
                let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
                selectVC.kind = .newAdd
                self?.navigationController?.pushViewController(selectVC, animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
}

extension MyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(320 / dataSource.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyListCell", for: indexPath) as! MyListCell
        let data = dataSource[indexPath.row]
        cell.bind(data)
        cell.bgView.backgroundColor = vm.cellBackgroundColor(indexPath.row)
        cell.backgroundColor = vm.cellBackgroundLastColor(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        clickCell = cell
        
        let scene = dataSource[indexPath.row]
        LSLUser.current().scene = scene
        let lockVC: HomeViewController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(lockVC, animated: true)
        if let visiableRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visiableRows, with: .automatic)
        }
    }
}
