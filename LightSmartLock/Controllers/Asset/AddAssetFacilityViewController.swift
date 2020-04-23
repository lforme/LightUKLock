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

class AddAssetFacilityCell: UICollectionViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    var disposeBag = DisposeBag()
    
    var model: String! {
        didSet {
            textLabel.text = model
        }
    }
    
}

class AddAssetFacilityViewController: UIViewController {
    
    @IBOutlet var configButtons: [ConfigButton]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    var items = BehaviorRelay<[String]>.init(value: [])
    
    var addAssetFacilities: (([AssetFacilityListModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .top
        
        addButton.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                let alertController = UIAlertController(title: "添加自定义配置", message: "", preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.placeholder = "输入自定义配置名称"
                }
                let confirmAction = UIAlertAction(title: "设置", style: .default) { [weak alertController] _ in
                    guard let alertController = alertController,
                        let textField = alertController.textFields?.first,
                        let text = textField.text else { return }
                    var value = self?.items.value ?? []
                    value.append(text)
                    self?.items.accept(value)
                }
                alertController.addAction(confirmAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        
        items
            .bind(to: collectionView.rx.items(cellIdentifier: "AddAssetFacilityCell", cellType: AddAssetFacilityCell.self)) { (row, element, cell) in
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
    
    @IBAction func save(_ sender: Any) {
        let buttonModels = configButtons
            .filter { $0.isSelected }
            .compactMap { $0.title(for: .normal)}
            .map(AssetFacilityListModel.init)
        let addModels = items.value            .map(AssetFacilityListModel.init)
        let all = buttonModels + addModels
        addAssetFacilities?(all)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectAction(_ sender: ConfigButton) {
        sender.isSelected = !sender.isSelected
    }
}
