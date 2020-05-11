//
//  BookKeepingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class BookKeepingFeeCell: UITableViewCell {
    
    @IBOutlet weak var feesButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingAddCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingTimeCell: UITableViewCell {
    
    @IBOutlet weak var timePickButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}


class BookKeepingController: UITableViewController {
    
    var assetId: String?
    var contractId: String?
    var vm: BookKeepingViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "记一笔"
        setupUI()
        bind()
    }
    
    func bind() {
        guard let assetId = self.assetId, let contractId = self.contractId else {
            HUD.flash(.label("无法获取资产信息"), delay: 2)
            return
        }
        self.vm = BookKeepingViewModel(assetId: assetId, contractId: contractId)
        tableView.reloadData()
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return vm?.itemList.count ?? 0
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 140
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 8
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row != 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            vm?.deleteItemBy(index: indexPath.row, complete: {[weak self] in
                self?.tableView.reloadSections([0], animationStyle: .automatic)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            vm?.addItem {[weak self] in
                self?.tableView.reloadSections([0], animationStyle: .automatic)
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingFeeCell", for: indexPath) as! BookKeepingFeeCell
            if let bindModel = vm?.itemList[indexPath.row] {
                
                cell.priceTextField.rx.text.orEmpty.changed
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .distinctUntilChanged().bind(to: bindModel.obAmount)
                    .disposed(by: cell.disposeBag)
                if let price = bindModel.convertToAddFlowParameter().amount {
                    cell.priceTextField.text = price
                }
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingAddCell", for: indexPath) as! BookKeepingAddCell
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingTimeCell", for: indexPath) as! BookKeepingTimeCell
            return cell
            
        default:
            fatalError()
        }
    }
}
