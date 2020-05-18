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
import HandyJSON

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

struct UtilitiesRecordsModel: HandyJSON {
    var totalFee: Double?
    var totalUse: Double?
    struct YearVOList: HandyJSON {
        var gage: String?
        var payFee: String?
        var recordDate: String?
    }
    var yearVOList: [YearVOList]?
}

class UtilitiesRecordsCell: UITableViewCell {
    
    @IBOutlet weak var recordDateLabel: UILabel!
    
    @IBOutlet weak var gageLabel: UILabel!
    
    @IBOutlet weak var payFeeLabel: UILabel!
    
    func config(with model: UtilitiesRecordsModel.YearVOList) {
        recordDateLabel.text = model.recordDate
        gageLabel.text = model.gage
        payFeeLabel.text = "¥\(model.payFee ?? "0")"
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


class UtilitiesRecordsViewController: AssetBaseViewController {
    
    
    @IBOutlet weak var waterButton: UtilitiesButton!
    
    @IBOutlet weak var elecButton: UtilitiesButton!
    
    @IBOutlet weak var gasButton: UtilitiesButton!
    
    @IBOutlet weak var totalUseLabel: UILabel!
    
    @IBOutlet weak var totalUseUnitLabel: UILabel!
    
    @IBOutlet weak var totalFeeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var yearButton: DataSelectionButton!
    
    
    private let listRelay = PublishRelay<[UtilitiesRecordsModel.YearVOList]>()
    private let typeRelay = BehaviorRelay<UtilitiesType>.init(value: .water)
    private let yearRelay = BehaviorRelay<Int>.init(value: 2020)
    
    var assetId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearButton.items = [["2019", "2020", "2021"]]
        yearButton.didUpdated = { [weak self]results in
            if let row = results.first?.value,
                let value = Int(row){
                self?.yearRelay.accept(value)
                self?.yearButton.setTitle("\(value)年", for: .normal)
            }
        }
        tableView.tableFooterView = UIView()
        
        listRelay
            .bind(to: tableView.rx.items(cellIdentifier: "UtilitiesRecordsCell", cellType: UtilitiesRecordsCell.self)) { (row, element, cell) in
                cell.config(with: element)
        }
        .disposed(by: rx.disposeBag)
        
        let water = waterButton.rx.tap
            .startWith(())
            .map { UtilitiesType.water}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = true
                self?.elecButton.isSelected = false
                self?.gasButton.isSelected = false
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
            })
        
        
        let elec = elecButton.rx.tap
            .map { UtilitiesType.elec}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = false
                self?.elecButton.isSelected = true
                self?.gasButton.isSelected = false
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
            })
        
        
        let gas = gasButton.rx.tap
            .map { UtilitiesType.gas}
            .do(onNext: { [weak self](type) in
                self?.waterButton.isSelected = false
                self?.elecButton.isSelected = false
                self?.gasButton.isSelected = true
                self?.totalUseUnitLabel.text = "总消耗量(\(type.unit))"
            })
        
        Observable.merge(water, elec, gas)
            .bind(to: self.typeRelay)
            .disposed(by: rx.disposeBag)
        
        
        Observable.combineLatest(typeRelay, yearRelay)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [unowned self]type, year -> Observable<UtilitiesRecordsModel> in
                return BusinessAPI2.requestMapJSON(.getUtilitiesRecords(assetId: self.assetId, year: year, type: type), classType: UtilitiesRecordsModel.self)
        }
        .subscribe(onNext: { [weak self](model) in
            self?.config(with: model)
        })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    func config(with model: UtilitiesRecordsModel) {
        self.totalUseLabel.text = "\(model.totalUse ?? 0)"
        self.totalFeeLabel.text = "¥\(model.totalFee ?? 0)"
        self.listRelay.accept(model.yearVOList ?? [])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddUtilitiesRecordViewController {
            vc.type = self.typeRelay.value
            vc.assetId = self.assetId
            vc.saveSuccess = { [unowned self] in
                let value = self.typeRelay.value
                self.typeRelay.accept(value)
            }
        }
    }
    
    
}
