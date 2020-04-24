//
//  UtilitiesRecordsViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/24.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum UtilitiesType: Int, Codable {
    case water = 1
    case elec
    case gas
    
    var text: String {
        switch self {
        case .water:
            return "水"
        case .elec:
            return "电"
        case .gas:
            return "气"
        }
    }
    
    var unit: String {
         switch self {
         case .water:
             return "吨"
         case .elec:
             return "度"
         case .gas:
             return "方"
         }
     }
    
}

struct UtilitiesRecordsModel: Codable {
    let totalFee: Int?
    let totalUse: Int?
    struct YearVOList: Codable {
        let gage: String?
        let payFee: String?
        let recordDate: String?
    }
    let yearVOList: [YearVOList]?
}

class UtilitiesRecordsCell: UITableViewCell {
    
    @IBOutlet weak var recordDateLabel: UILabel!
    
    @IBOutlet weak var gageLabel: UILabel!
    
    @IBOutlet weak var payFeeLabel: UILabel!
    
    func config(with model: UtilitiesRecordsModel.YearVOList) {
        recordDateLabel.text = model.recordDate
        gageLabel.text = model.gage
        payFeeLabel.text = model.payFee
    }
    
}

class UtilitiesButton: UIButton {

    override func awakeFromNib() {
          super.awakeFromNib()
          cornerRadius = 4
          setTitleColor(#colorLiteral(red: 0.3254901961, green: 0.5843137255, blue: 0.9137254902, alpha: 1), for: .selected)
          setTitleColor(.black, for: .normal)
          tintColor = .clear
      }
}


class UtilitiesRecordsViewController: UIViewController {
    
    
    @IBOutlet weak var waterButton: UtilitiesButton!
    
    @IBOutlet weak var elecButton: UtilitiesButton!
    
    @IBOutlet weak var gasButton: UtilitiesButton!
    
    @IBOutlet weak var totalUseLabel: UILabel!
    
    @IBOutlet weak var totalUseUnitLabel: UILabel!
    
    @IBOutlet weak var totalFeeLabel: UILabel!
        
    @IBOutlet weak var tableView: UITableView!
    
    private let listRelay = PublishRelay<[UtilitiesRecordsModel.YearVOList]>()
    private let typeRelay = BehaviorRelay<UtilitiesType>.init(value: .water)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        waterButton.rx.tap
            .startWith(())
            .map { UtilitiesType.water}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = true
                self?.elecButton.isSelected = false
                self?.gasButton.isSelected = false
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
                self?.typeRelay.accept(type)
            })
            .subscribe(onNext: { (_) in
                print("water")
            })
            .disposed(by: rx.disposeBag)
        
        elecButton.rx.tap
            .map { UtilitiesType.elec}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = false
                self?.elecButton.isSelected = true
                self?.gasButton.isSelected = false
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
                self?.typeRelay.accept(type)
            })
            .subscribe(onNext: { (_) in
                print("elec")
            })
            .disposed(by: rx.disposeBag)
        
        gasButton.rx.tap
            .map { UtilitiesType.gas}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = false
                self?.elecButton.isSelected = false
                self?.gasButton.isSelected = true
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
                self?.typeRelay.accept(type)
            })
            .subscribe(onNext: { (_) in
                print("gas")
            })
            .disposed(by: rx.disposeBag)
        
        listRelay
            .bind(to: tableView.rx.items(cellIdentifier: "UtilitiesRecordsCell", cellType: UtilitiesRecordsCell.self)) { (row, element, cell) in
                cell.config(with: element)
        }
        .disposed(by: rx.disposeBag)
        
        
    
    }
    
    func config(with model: UtilitiesRecordsModel) {
        self.totalUseLabel.text = "\(model.totalUse ?? 0)"
        self.totalFeeLabel.text = "\(model.totalFee ?? 0)"
        self.listRelay.accept(model.yearVOList ?? [])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddUtilitiesRecord",
            let vc = segue.destination as? AddUtilitiesRecordViewController {
            vc.type = self.typeRelay.value
        }
    }
    
    
}
