//
//  AssetFacilityListViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON
import PKHUD
import RxRelay

class LadderAssetFacilityVO: HandyJSON {
    
    var facilityName: String?
    var id: String?
    var remark: String?
    
    var isSelected = false
    
    init(facilityName: String?) {
        self.facilityName = facilityName
        self.id = nil
        self.remark = nil
    }
    
    required init() {
    }
    
}

class AssetFacilityListCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var remarkTF: UITextField!
    
    var disposeBag = DisposeBag()
    
    var model: LadderAssetFacilityVO! {
        didSet {
            deleteButton.setTitle(model.facilityName, for: .normal)
            remarkTF.text = model.remark
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        remarkTF.rx.text
            .subscribe(onNext: { [weak self](text) in
                self?.model?.remark = text
            })
            .disposed(by: rx.disposeBag)
    }
}


class AssetFacilityListViewController: AssetBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bottomContainer: ButtonContainerView!
    
    var assetId: String!
    
    var items = BehaviorRelay<[LadderAssetFacilityVO]>.init(value: [])
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        
        BusinessAPI2.requestMapJSONArray(.getFacilities(assetId: assetId), classType: LadderAssetFacilityVO.self)
            .map { $0.compactMap { $0 }}
            .bind(to: items)
            .disposed(by: rx.disposeBag)
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "AssetFacilityListCell", cellType: AssetFacilityListCell.self)) { (row, element, cell) in
                cell.model = element
                cell.disposeBag = DisposeBag()
                cell.deleteButton.rx.tap
                    .subscribe(onNext: { [weak self](_) in
                        var value = self?.items.value
                        value?.remove(at: row)
                        self?.items.accept(value ?? [])
                    })
                    .disposed(by: cell.disposeBag)
        }
        .disposed(by: rx.disposeBag)
        
        saveButton.rx.tap
            .asObservable()
            .flatMapLatest { [unowned self]_ in
                return BusinessAPI2.requestMapAny(.saveFacilities(assetId: self.assetId, models: self.items.value))
                    .catchErrorJustReturn("保存失败，请重试！")
        }
        .subscribe(onNext: { (response) in
            var message: String?
            if let response = response as? [String: Any] {
                if let status = response["status"] as? Int, status == 200 {
                    message = "保存成功"
                } else {
                    message = response["message"] as? String
                }
                
            } else {
                message = response as? String
            }
            HUD.flash(.label(message))
        })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAssetFacility",
            let vc = segue.destination as? AddAssetFacilityViewController {
            vc.addAssetFacilities = { [weak self] newItems in
                let all = (self?.items.value ?? []) + newItems
                self?.items.accept(all)
            }
            vc.assetId = assetId
        }
    }
    
    
}
