//
//  ConfirmArrivalController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class ConfirmArrivalController: UITableViewController {
    
    var billId = ""
    var totalMoney: Double = 0.00
    let obDate = BehaviorRelay<String>(value: Date().toFormat("yyyy-MM-dd hh:mm:ss"))
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountWayLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "确认到账"
        setupUI()
        bind()
    }
    
    func bind() {
        obDate.bind(to: dateLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 80
        }
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:
            let receivingAccountVC: ReceivingAccountController = ViewLoader.Storyboard.controller(from: "Bill")
            self.navigationController?.pushViewController(receivingAccountVC, animated: true)
        case 2:
            DatePickerController.rx.present(with: "yyyy-MM-dd hh:mm:ss", mode: .date, maxDate: nil, miniDate: Date()).bind(to: obDate).disposed(by: rx.disposeBag)
        default:
            break
        }
    }
}
