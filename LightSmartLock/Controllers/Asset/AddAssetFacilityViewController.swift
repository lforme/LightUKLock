//
//  AddAssetFacilityViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/23.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlignedCollectionViewFlowLayout
import HandyJSON
import PKHUD

extension NSNotification.Name {
    static let deleteFacility = NSNotification.Name("deleteFacility")
}

class AddAssetFacilityCell: UICollectionViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var configButton: ConfigButton!
    
    @IBAction func selectAction(_ sender: ConfigButton) {
        sender.isSelected = !sender.isSelected
        model.isSelected = sender.isSelected
    }
    
    var disposeBag = DisposeBag()
    
    var index: Int!
    
    var model: LadderAssetFacilityVO! {
        didSet {
            disposeBag = DisposeBag()
            configButton.setTitle(model.facilityName, for: .normal)
            configButton.isSelected = model.isSelected
            deleteButton.rx.tap
                .asObservable()
                .flatMapLatest { [unowned self]_ in
                    
                    return BusinessAPI2.requestMapAny(.deleteFacility(id: self.model.id ?? ""))
                        .catchErrorJustReturn("删除失败，请重试！")
            }
            .subscribe(onNext: { [unowned self](response) in
                var message: String?
                if let response = response as? [String: Any] {
                    if let status = response["status"] as? Int, status == 200 {
                        message = "删除成功"
                        if let index = self.index {
                            NotificationCenter.default.post(name: .deleteFacility, object: nil, userInfo: ["index": index])
                        }
                        
                    } else {
                        message = response["message"] as? String
                    }
                    
                } else {
                    message = response as? String
                }
                
                HUD.show(.label(message))
                
            })
                .disposed(by: disposeBag)
            
        }
    }
}

class ConstantAssetFacilityCell: UICollectionViewCell {
    
    @IBOutlet weak var configBtn: ConfigButton!
    
    var model: LadderAssetFacilityVO! {
        didSet {
            configBtn.setTitle(model.facilityName, for: .normal)
            configBtn.isSelected = model.isSelected
        }
    }
    
    @IBAction func selectAction(_ sender: ConfigButton) {
        sender.isSelected = !sender.isSelected
        model.isSelected = sender.isSelected
    }
}


class ConfigButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 4
        setTitleColor(.white, for: .selected)
        setTitleColor(.black, for: .normal)
        tintColor = .clear
        isSelected = false
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1)
                borderColor = nil
                borderWidth = 0
            } else {
                backgroundColor = .white
                borderColor = .lightGray
                borderWidth = 1
            }
        }
    }
}

class LadderFacilityQueryVO: HandyJSON {
    var constants: [LadderAssetFacilityVO]?
    var custom: [LadderAssetFacilityVO]?
    
    required init() {
    }
}


class AddAssetFacilityViewController: UIViewController {
    
    @IBOutlet weak var constansCollectionView: UICollectionView!
    
    @IBOutlet weak var customCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var assetId: String!
    
    var addAssetFacilities: (([LadderAssetFacilityVO]) -> Void)?
    let addRelay = BehaviorRelay<String?>(value: nil)
    let constantsRelay = BehaviorRelay<[LadderAssetFacilityVO]>.init(value: [])
    let customRelay = BehaviorRelay<[LadderAssetFacilityVO]>.init(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let constantsFlowLayout = constansCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        constantsFlowLayout?.horizontalAlignment = .left
        constantsFlowLayout?.verticalAlignment = .top
        
        
        let customFlowLayout = customCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        customFlowLayout?.horizontalAlignment = .left
        customFlowLayout?.verticalAlignment = .top
        
        let all = BusinessAPI2.requestMapJSON(.getFacilityList(assetId: self.assetId), classType: LadderFacilityQueryVO.self)
            .map { $0 as LadderFacilityQueryVO? }
            .catchErrorJustReturn(nil)
        
        all.map { $0?.constants ?? []}
            .bind(to: constantsRelay)
            .disposed(by: rx.disposeBag)
        
        constantsRelay
            .bind(to: constansCollectionView.rx.items(cellIdentifier: "ConstantAssetFacilityCell", cellType: ConstantAssetFacilityCell.self)) { (row, element, cell) in
                cell.model = element
        }
        .disposed(by: rx.disposeBag)
        
        all.map { $0?.custom ?? []}
            .bind(to: customRelay)
            .disposed(by: rx.disposeBag)
        
        customRelay
            .bind(to: customCollectionView.rx.items(cellIdentifier: "AddAssetFacilityCell", cellType: AddAssetFacilityCell.self)) { (row, element, cell) in
                cell.model = element
                cell.index = row
        }
        .disposed(by: rx.disposeBag)
        
        
        addButton.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                let alertController = UIAlertController(title: "添加自定义配置", message: "", preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.placeholder = "输入自定义配置名称"
                }
                let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak alertController] _ in
                    guard let alertController = alertController,
                        let textField = alertController.textFields?.first,
                        let text = textField.text,
                        !text.isEmpty else { return }
                    self?.addRelay.accept(text)
                }
                alertController.addAction(confirmAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        addRelay.asObservable()
            .flatMapLatest { [unowned self]name -> Observable<Any> in
                guard let name = name else {
                    return .empty()
                }
                return BusinessAPI2.requestMapAny(.addFacility(assetId: self.assetId, name: name))
                    .catchErrorJustReturn("添加失败，请重试！")
        }
        .subscribe(onNext: { [weak self](response) in
            var message: String?
            if let response = response as? [String: Any] {
                if let status = response["status"] as? Int, status == 200 {
                    message = "添加成功"
                    let model = LadderAssetFacilityVO()
                    model.id = response["data"] as? String
                    model.facilityName = self?.addRelay.value
                    let items = self?.customRelay.value ?? []
                    self?.customRelay.accept((items + [model]))
                } else {
                    message = response["message"] as? String
                }
                
            } else {
                message = response as? String
            }
            
            HUD.show(.label(message))
            
        })
            .disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx
            .notification(.deleteFacility)
            .subscribe(onNext: { [unowned self](noti) in
                if let index = noti.userInfo?["index"] as? Int {
                    var items = self.customRelay.value
                    items.remove(at: index)
                    self.customRelay.accept(items)
                }
            })
            .disposed(by: rx.disposeBag)
        
        
    }
    
    @IBAction func save(_ sender: Any) {
        let constants = constantsRelay.value.filter { $0.isSelected }
        let custom = customRelay.value.filter { $0.isSelected }
        let all = constants + custom
        addAssetFacilities?(all)
        self.navigationController?.popViewController(animated: true)
    }
}
