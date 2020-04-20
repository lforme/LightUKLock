//
//  PositioEditingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class PositioEditingController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    enum SelectType: Int {
        case name = 0
        case area
        case houseType
        case towards
        case buildingNumber
    }
    
    @IBOutlet weak var areaTextfield: UITextField!
    @IBOutlet weak var houseType: UILabel!
    @IBOutlet weak var plotName: UILabel!
    @IBOutlet weak var towardLabel: UILabel!
    @IBOutlet weak var buildingNumber: UILabel!
    
    var navigationRightButton: UIButton!
    var vm: PositionViewModel!
    var id: String?
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "安装位置"
        
        self.vm = PositionViewModel(id: id)
        
        setupUI()
        bind()
        setupNavigationRightItem()
        
    }
    
    func bind() {
        self.vm.defaultPositionModel.subscribe(onNext: {[weak self] (defaultModel) in
            self?.plotName.text = defaultModel?.buildingName
            if let area = defaultModel?.area?.description {
                self?.areaTextfield.text = area
            }
            
            self?.houseType.text = defaultModel?.houseStruct
            
            var building = ""
            if let b = defaultModel?.buildingNo, !b.isEmpty {
                building += b
            }
            
            if let n = defaultModel?.houseNum, !n.isEmpty {
                building += n
            }
            
            if let p = defaultModel?.floor?.description, !p.isEmpty {
                building += p
            }
            self?.buildingNumber.text = building
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        areaTextfield.rx.text.orEmpty.changed.bind(to: vm.obArea).disposed(by: rx.disposeBag)
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        
        self.navigationRightButton = self.createdRightNavigationItem(title: "", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 0, color: .white)
        self.navigationRightButton.contentHorizontalAlignment = .trailing
        self.navigationRightButton.addTarget(self, action: #selector(self.doneActionTap), for: .touchUpInside)
        
        self.vm.buttonType.subscribe(onNext: {[weak self] (btnType) in
            guard let this = self else { return }
            switch btnType {
            case .delete:
                this.navigationRightButton.setTitle("删除", for: UIControl.State())
            case .save:
                this.navigationRightButton.setTitle("保存", for: UIControl.State())
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    @objc func doneActionTap() {
        self.vm.buttonType.flatMapLatest {[weak self] (buttonType) -> Observable<Bool> in
            guard let this = self else {
                return .empty()
            }
            switch buttonType {
            case .delete:
                
                if LSLUser.current().isInstalledLock {
                    return this.showAlert(title: "删除资产前请先到门锁设置中删除门锁", message: nil, buttonTitles: ["知道啦"], highlightedButtonIndex: 0).map { _ in false }
                } else {
                    return this.showAlert(title: "确定删除资产吗？删除后不能撤销", message: nil, buttonTitles: ["取消", "删除"], highlightedButtonIndex: 0).map { $0 == 1 }.flatMapLatest { (delete) -> Observable<Bool> in
                        if delete {
                            return this.vm.delete()
                        } else {
                            return .just(false)
                        }
                    }
                }
                
            case .save:
                return this.vm.save()
            }
        }.subscribe(onNext: {[weak self] (success) in
            guard let this = self else { return }
            if success {
                BluetoothPapa.shareInstance.reboot { (_) in
                    // 写入门锁
                }
                
                HUD.flash(.label("操作成功"), delay: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    this.navigationController?.popToRootViewController(animated: true)
                }
                 NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.addLock)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = SelectType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .name:
            let searchVC: SearchPlotController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(searchVC, animated: true)
            searchVC.didSelectedItem {[weak self] (item) in
                self?.vm.setupPosition(item.name, city: item.cityname, region: item.address)
            }
            
        case .area:
            break
            
        case .houseType:
            let shi = PositionViewModel.Config.houseType.map {"\($0)室"}
            let ting = PositionViewModel.Config.houseType.map {"\($0)厅"}
            let wei = PositionViewModel.Config.houseType.map {"\($0)卫"}
            DataPickerController.rx.present(with: "选择户型", items: [shi, ting, wei]).subscribe(onNext: {[weak self] (result) in
                let houseType = result.compactMap({ (r) -> String? in
                    return r.value
                }).reduce("", { (next, acc) -> String in
                    return next + acc
                })
                self?.vm.setupHouseType(houseType)
            }).disposed(by: rx.disposeBag)
            
            
        case .towards:
            let towards = PositionViewModel.Config.towards
            DataPickerController.rx.present(with: "选择朝向", items: [towards]).subscribe(onNext: {[weak self] (result) in
                let towardsStr = result.compactMap({ (r) -> String? in
                    return r.value
                }).reduce("", { (next, acc) -> String in
                    return next + acc
                })
                self?.vm.setupTowards(towardsStr)
            }).disposed(by: rx.disposeBag)
            
        case .buildingNumber:
            let setBuildingNumberVC: SetBuildingNumberController = ViewLoader.Storyboard.controller(from: "Home")
            setBuildingNumberVC.fetchCallback {[weak self] (building, unit, doorplate) in
                self?.vm.setupBuildingInfo(building, uniti: unit, doorPlate: doorplate)
            }
            navigationController?.pushViewController(setBuildingNumberVC, animated: true)
        }
    }
    
}
