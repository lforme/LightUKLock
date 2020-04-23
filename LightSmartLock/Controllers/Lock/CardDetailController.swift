//
//  CardDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class CardDetailController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    enum SelectType: Int {
        case changeName = 0
        case delete
    }
    
    @IBOutlet weak var cardNameLabel: UILabel!
    
    var keyNumber: String!
    var keyId: String!
    var cardName: String?
    
    var vm: CardDetailViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "门卡详情"
        setupUI()
        bind()
    }
    
    func bind() {
        self.vm = CardDetailViewModel(keyNumber: self.keyNumber, keyId: self.keyId)
        self.cardNameLabel.text = self.cardName
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = SelectType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .delete:
            Popups.showSelect(title: "请选择删除方式", indexTitleOne: "现场删除", IndexTitleTwo: "远程删除", contentA: "请在门锁附近(2-3米内)打开手机蓝牙删除门卡，删除后立即生效", contentB: "请在门锁附近(2-3米内)打开手机蓝牙删除门卡，删除后立即生效").flatMapLatest {[unowned self] (index) -> Observable<Bool> in
                let way = CardDetailViewModel.DeleteWay(rawValue: index)
                return self.vm.deleteCard(way: way!)
            }.subscribe(onNext: {[weak self] (success) in
                if success {
                    HUD.flash(.label("删除门卡成功"), delay: 2)
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.addCard)
                    guard let tagerVC = self?.navigationController?.children.filter({ (vc) -> Bool in
                        return vc is CardManageController
                    }).last else { return }
                    self?.navigationController?.popToViewController(tagerVC, animated: true)
                    
                }
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
            
        case .changeName:
            SingleInputController.rx.present(wiht: "修改门卡名称", saveTitle: "保存", placeholder: self.cardName).flatMapLatest {[unowned self] (newName) -> Observable<Bool> in
                return self.vm.changeCardName(newName)
            }.subscribe(onNext: {[weak self] (success) in
                if success {
                    NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.addCard)
                    HUD.flash(.label("修改门卡名称成功"), delay: 2)
                } else {
                    HUD.flash(.label("修改门卡名称失败"), delay: 2)
                }
                
                self?.navigationController?.popViewController(animated: true)
                
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
}
