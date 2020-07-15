//
//  BindingOrEditAssetViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/15.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import PKHUD

class BindingOrEditAssetViewController: AssetBaseViewController {
    
    var assetId: String = ""
    var asset = PositionModel()
    
    @IBOutlet weak var cityBtn: UIButton!
    
    @IBOutlet weak var buildingNameBtn: UIButton!
    
    @IBOutlet weak var buildingNoTF: UITextField!
    
    @IBOutlet weak var floorTF: UITextField!
    
    @IBOutlet weak var houseNumTF: UITextField!
    
    @IBOutlet weak var areaTF: UITextField!
    
    @IBOutlet weak var houseStructBtn: UIButton!
    
    var deleteButton: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayDefaultValue()
        fetchData()
        
        buildingNoTF.rx
            .text
            .orEmpty
            .changed.subscribe(onNext: {[weak self] (buildingNumber) in
                self?.asset.houseNum = buildingNumber
            }).disposed(by: rx.disposeBag)
        
        saveBtn.rx.tap
            .flatMap { [unowned self]_ -> Observable<PositionModel> in
                
                guard let _ = self.asset.cityName else {
                    HUD.flash(.label("请选择城市"))
                    return .empty()
                }
                
                guard let _ = self.asset.buildingName else {
                    HUD.flash(.label("请选择小区"))
                    return .empty()
                }
                
                guard let houseNum = self.houseNumTF.text, houseNum.isNotEmpty else {
                    HUD.flash(.label("请填写房号"))
                    return .empty()
                }
                
                self.asset.buildingNo = self.buildingNoTF.text
                self.asset.floor = self.floorTF.text?.toInt()
                self.asset.houseNum = self.houseNumTF.text
                self.asset.area = self.areaTF.text?.toDouble()
                return .just(self.asset)
        }
        .flatMapLatest { asset in
            return BusinessAPI.requestMapAny(.editAssetHouse(parameter: asset))
        }
        .subscribe(onNext: { [weak self](response) in
            if let response = response as? [String: Any] {
                if let status = response["status"] as? Int, status == 200 {
                    HUD.flash(.label("操作成功"), onView: nil, delay: 0.5) { _ in
                        NotificationCenter.default.post(name: .refreshAssetDetail, object: nil)
                        NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.updateScene)
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                } else {
                    HUD.flash(.label("操作失败"))
                }
            } else {
                HUD.flash(.label("操作失败"))
            }
        })
            .disposed(by: rx.disposeBag)
        
        setupNavigationRightItem()
    }
    
    func setupNavigationRightItem() {
        deleteButton = self.createdRightNavigationItem(title: "删除资产", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 0, color: .white)
        deleteButton.contentHorizontalAlignment = .trailing
        deleteButton.isHidden = asset.id.isNilOrEmpty
        
        deleteButton.rx.tap
            .flatMapLatest {[weak self] (_) -> Observable<Int> in
                guard let this = self else {
                    return .empty()
                }
                
                if LSLUser.current().isInstalledLock {
                    return this.showAlert(title: "提示", message: "删除资产前请先到门锁设置中删除门锁", buttonTitles: ["知道了"], highlightedButtonIndex: 0)
                } else {
                    return this.showAlert(title: "提示", message: "确定删除资产吗？删除后不能撤销", buttonTitles: ["删除", "取消"], highlightedButtonIndex: 1)
                }
        }.flatMapLatest {[unowned self] (buttonIndex) -> Observable<Bool> in
            if buttonIndex == 0 {
                return BusinessAPI.requestMapBool(.deleteAssetHouse(id: self.asset.id!))
            } else {
                return .empty()
            }
        }.subscribe(onNext: {[unowned self] (success) in
            if success {
                HUD.flash(.label("操作成功"), delay: 2)
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.deleteScene)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CitySelectViewController,
            let btn = sender as? UIButton
        {
            vc.didSelectCitt = {[weak self] city in
                btn.setTitle(city.name, for: .normal)
                self?.asset.cityId = city.code.description
                self?.asset.cityName = city.name
                print(city.code ?? "")
            }
        }
    }
    
    
    @IBAction func searchPlotAction(_ sender: UIButton) {
        let searchVC: SearchPlotController = ViewLoader.Storyboard.controller(from: "Home")
        navigationController?.pushViewController(searchVC, animated: true)
        searchVC.didSelectedItem {[weak self] (item) in
            self?.asset.address = item.address
            self?.asset.buildingName = item.name
            sender.setTitle(item.name, for: .normal)
        }
    }
    
    @IBAction func selectHouseStructAction(_ sender: UIButton) {
        
        let shi = PositionViewModel.Config.houseType.map {"\($0)室"}
        let ting = PositionViewModel.Config.houseType.map {"\($0)厅"}
        let wei = PositionViewModel.Config.houseType.map {"\($0)卫"}
        DataPickerController.rx.present(with: "选择户型", items: [shi, ting, wei]).subscribe(onNext: {[weak self] (result) in
            let houseStruct = result.compactMap({ (r) -> String? in
                return r.value
            }).reduce("", { (next, acc) -> String in
                return next + acc
            })
            self?.asset.houseStruct = houseStruct
            self?.houseStructBtn.setTitle(houseStruct, for: .normal)
        }).disposed(by: rx.disposeBag)
    }
    
    private func fetchData() {
        
        let getAssetHouseDetail = BusinessAPI.requestMapJSON(.getAssetHouseDetail(id: assetId), classType: PositionModel.self)
        
        getAssetHouseDetail.subscribe(onNext: { [weak self](detail) in
            self?.asset = detail
            self?.deleteButton.isHidden = detail.id.isNilOrEmpty
            self?.displayDefaultValue()
        })
            .disposed(by: rx.disposeBag)
    }
    
    private func displayDefaultValue() {
        cityBtn.setTitle(asset.cityName ?? "请选择", for: .normal)
        buildingNameBtn.setTitle(asset.buildingName ?? "请选择", for: .normal)
        buildingNoTF.text = asset.buildingNo
        floorTF.text = asset.floor?.description
        houseNumTF.text = asset.houseNum
        areaTF.text = asset.area?.description
        houseStructBtn.setTitle(asset.houseStruct ?? "请选择", for: .normal)
    }
}
