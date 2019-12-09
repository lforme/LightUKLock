//
//  UserDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class UserDetailController: UITableViewController {
    
    @IBOutlet weak var cell1: UITableViewCell!
    
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var cell2Label: UILabel!
    @IBOutlet weak var cell3Label: UILabel!
    @IBOutlet weak var cell4Label: UILabel!
    
    var model: UserMemberListModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户详情"
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
        
        if cell1.responds(to: #selector(setter: cell1.separatorInset)) {
            cell1.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        }
    }
    
    func bind() {
        nickname.text = model.customerNickName
        role.text = model.relationType?.description
        phone.text = model.phone
        
        guard let model = self.model else {
            return
        }
        
        if LSLUser.current().user?.accountID == model.accountID && model.relationType == .some(.superAdmin) {
            cell2Label.text = "永久密码"
            cell3Label.text = "指纹"
            cell4Label.text = "门卡"
        } else {
            cell2Label.text = "修改用户名称"
            cell3Label.text = "删除"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let model = self.model else {
            return 0
        }
        if LSLUser.current().user?.accountID == model.accountID && model.relationType == .some(.superAdmin) {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.model else { return }
        
        if LSLUser.current().user?.accountID == model.accountID && model.relationType == .some(.superAdmin) {
            
            switch indexPath.row {
            case 1:
                print("密码管理")
            case 2:
                print("指纹管理")
            case 3:
                print("门卡管理")
            default:
                break
            }
            
        } else {
            
            switch indexPath.row {
            case 1:
                print("修改用户名称")
            case 2:
                print("删除用户")
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
