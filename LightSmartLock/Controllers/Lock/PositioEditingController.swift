//
//  PositioEditingController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/2.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD

class PositioEditingController: UITableViewController {
    
    enum SelectType: Int {
        case name = 0
        case area
        case houseType
        case towards
        case buildingNumber
    }
    
    enum EditingType {
        case addNew
        case modify
    }
    
    var editinType: EditingType = .modify
    
    @IBOutlet weak var areaTextfield: UITextField!
    @IBOutlet weak var houseType: UILabel!
    @IBOutlet weak var plotName: UILabel!
    @IBOutlet weak var towardLabel: UILabel!
    @IBOutlet weak var buildingNumber: UILabel!
    
    var vm: PositionViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "安装位置"
        setupUI()
        bind()
        setupNavigationRightItem()
        
    }
    
    func bind() {
        self.vm = PositionViewModel(type: self.editinType)
        
        self.vm.defaultPositionModel.subscribe(onNext: {[weak self] (defaultModel) in
            self?.plotName.text = defaultModel.villageName
            self?.areaTextfield.text = defaultModel.area
            self?.houseType.text = defaultModel.houseType
            self?.towardLabel.text = defaultModel.towards
            
            var building = ""
            if let b = defaultModel.building {
                building += b
            }
            if let p = defaultModel.doorplate, !p.isEmpty {
                building += "-"
                building += p
            }
            self?.buildingNumber.text = building
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        self.vm.buttonType.subscribe(onNext: {[weak self] (btnType) in
            guard let this = self else { return }
            switch btnType {
            case .delete:
                let button = this.createdRightNavigationItem(title: "删除", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 0, color: ColorClassification.primary.value)
                button.contentHorizontalAlignment = .trailing
            case .save:
                let button = this.createdRightNavigationItem(title: "保存", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 0, color: ColorClassification.primary.value)
                button.contentHorizontalAlignment = .trailing
                
            }
        }).disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = SelectType.init(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .name:
            break
            
        case .area:
            break
            
        case .houseType:
            break
            
        case .towards:
            break
            
        case .buildingNumber:
            break
        }
    }
    
}
