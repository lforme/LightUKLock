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

class LadderAssetFacilityVO: HandyJSON {

    var facilityName: String?
    var id: String?
    var remark: String?
    
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


class AssetFacilityListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bottomContainer: ButtonContainerView!
    
    var assetId: String!
    
    var items = BehaviorRelay<[LadderAssetFacilityVO]>.init(value: [])
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        
        let items =         BusinessAPI2.requestMapJSONArray(.getFacilities(assetId: assetId), classType: LadderAssetFacilityVO.self)
        
        items
            .do(onNext: { [weak self](models) in
                self?.bottomContainer.isHidden = models.isEmpty
            })
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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAssetFacility",
            let vc = segue.destination as? AddAssetFacilityViewController {
            vc.addAssetFacilities = { [weak self] newItems in
                let all = (self?.items.value ?? []) + newItems
                self?.items.accept(all)
            }
        }
    }
    
    
}
