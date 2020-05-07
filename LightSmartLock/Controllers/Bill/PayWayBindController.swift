//
//  PayWayBindController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class PayWayBindController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var qrLabel: UILabel!
    @IBOutlet weak var pickQrButton: UIButton!
    @IBOutlet weak var defaultSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    enum PayWay {
        case wechat
        case ali
    }
    
    var canEditing: Bool = false
    var payWay: PayWay = .wechat
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
        setupNavigationRightItem()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationRightItem() {
        if canEditing {
            createdRightNavigationItem(title: "删除", image: nil)
        }
    }
    
    func bind() {
        switch payWay {
        case .ali:
            title = "绑定支付宝支付"
            nameLabel.text = "真实姓名"
            nameTextField.placeholder = "请输入真实姓名"
            accountLabel.text = "支付宝账号"
            accountTextField.placeholder = "请输入支付宝账号"
            qrLabel.text = "支付宝收款码"
        case .wechat:
            title = "绑定微信支付"
            nameLabel.text = "微信昵称"
            nameTextField.placeholder = "请输入微信昵称"
            accountLabel.text = "微信账号"
            accountTextField.placeholder = "请输入微信账号"
            qrLabel.text = "微信收款码"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 80
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
