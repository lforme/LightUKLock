//
//  PasswordManagementController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate

class PasswordManagementController: UITableViewController, NavigationSettingStyle {
    
    enum SelectType: Int {
        case longtime = 0
        case multiple
        case temporary
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var longPwdDes: UILabel!
    @IBOutlet weak var multiplePwdDes: UILabel!
    @IBOutlet weak var tempPwdDes: UILabel!
    
    let vm = PasswordManagementViewModel()
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "密码管理"
        self.clearsSelectionOnViewWillAppear = true
        
        setupUI()
        bind()
    }
    
    func bind() {
        vm.digitalPwdDisplay.subscribe(onNext: {[weak self] (model) in
            
            guard var password = model?.keySecret, password.count == 6 else {
                return
            }
            let index = password.index(password.startIndex, offsetBy: 3)
            password.insert(contentsOf: "--", at: index)
            password = password.replacingOccurrences(of: "--", with: " ")
            
            guard let time = model?.beginTime?.toDate() else {
                return
            }
            let useDay = time.date.getInterval(toDate: Date(), component: .day)
            self?.longPwdDes.text = "\(password)  密码已使用\(useDay)天"
            
            }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SelectType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .longtime:
            let digitalPwdVC: DigitalPwdDetailController = ViewLoader.Storyboard.controller(from: "Home")
            digitalPwdVC.vm = self.vm
            navigationController?.pushViewController(digitalPwdVC, animated: true)
        default:
            break
        }
    }
}
