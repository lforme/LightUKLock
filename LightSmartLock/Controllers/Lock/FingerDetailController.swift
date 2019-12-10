//
//  FingerDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift

class FingerDetailController: UITableViewController {
    
    enum SelectType: Int {
        case changeName = 0
        case delete = 10
    }
    
    @IBOutlet weak var fingerLabel: UILabel!
    @IBOutlet weak var forceSwitch: UISwitch!
    @IBOutlet weak var emergencyTextField: UITextField!
    var saveButton: UIButton!
    
    var fingerModel: FingerModel!
    var vm: FingerDetailViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "指纹详情"
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func bind() {
        
        fingerLabel.text = fingerModel.mark
        emergencyTextField.text = fingerModel.remindPhone
        if fingerModel.keyType == 201 {
            forceSwitch.isOn = true
        } else {
            forceSwitch.isOn = false
        }
        
        guard let id = fingerModel.keyID, let keyNum = fingerModel.keyNum else {
            HUD.flash(.label("无法从服务器获取指纹编号, 请稍后再试"), delay: 2)
            return
        }
        
        vm = FingerDetailViewModel(id: id, fingerNum: keyNum)
        
        forceSwitch.rx.value.subscribe(onNext: {[weak self] (open) in
            self?.vm.isForceFinger.accept(open)
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        emergencyTextField.rx.text.orEmpty.changed.bind(to: vm.forcePhone).disposed(by: rx.disposeBag)
        
        saveButton.rx.bind(to: vm.saveAction, input: ())
        
        vm.saveAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.saveAction.elements.subscribe(onNext: { (success) in
            if success {
                HUD.flash(.label("成功"), delay: 2)
            } else {
                HUD.flash(.label("失败"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
        
        vm.saveAction.executing.subscribe(onNext: { (exe) in
            if exe {
                HUD.show(.label("数据写入中..."))
            } else {
                HUD.hide(animated: true)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupNavigationRightItem() {
        self.saveButton = createdRightNavigationItem(title: "保存", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: ColorClassification.primary.value)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 26
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = SelectType(rawValue: indexPath.row + (indexPath.section * 10)) else {
            return
        }
        switch type {
        case .changeName:
            
            SingleInputController.rx.present(wiht: "设置指纹名称", saveTitle: "保存", placeholder: fingerModel.mark).flatMapLatest (self.vm.setFingerName).subscribe(onNext: { (success) in
                if success {
                    HUD.flash(.label("修改成功"), delay: 2)
                } else {
                    HUD.flash(.label("修改失败"), delay: 2)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
            
        case .delete:
            let share = Popups.showSelect(title: "选择删除方式", indexTitleOne: "现场删除", IndexTitleTwo: "远程删除", contentA: "请在门锁附近(2-3米内)打开手机蓝牙删除指纹，删除后立即生效", contentB: "请在网络信号通畅的地方删除，远程删除指纹需云端同步到门锁，可能会存在信号延迟，请稍后在密码管理中查看指纹状态").map { $0 == 1 }.share(replay: 1, scope: .forever)
            
            share.bind(to: vm.isRemote).disposed(by: rx.disposeBag)
            
            share.delay(1, scheduler: MainScheduler.instance).flatMapLatest {[unowned self] _ in self.vm.deleteFinger() }.subscribe(onNext: {[weak self] (success) in
                if success {
                    HUD.flash(.label("删除成功"), delay: 2)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    HUD.flash(.label("删除失败"), delay: 2)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return forceSwitch.isOn ? 3 : 2
        case 1:
            return 1
        default:
            return 0
        }
    }
}


