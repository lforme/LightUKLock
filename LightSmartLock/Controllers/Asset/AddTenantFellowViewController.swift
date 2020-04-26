//
//  AddTenantFellowViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class TenantMember: Codable {
    var id: String?
    var idCard: String?
    var idCardFront: String?
    var idCardReverse: String?
    var phone: String?
    var userName: String?
}

class AddTenantFellowViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var idCardTF: UITextField!
    
    @IBOutlet weak var idCardFrontBtn: UIButton!
    
    @IBOutlet weak var idCardReverseBtn: UIButton!
    
    var addFellow: ((TenantMember, Bool) -> Void)?
    
    var member: TenantMember!
    
    private var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEdit = member != nil
        titleLabel.text = isEdit ? "编辑同住人" : "添加同住人"
        member = member ?? TenantMember()
        userNameTF.text = member.userName
        phoneTF.text = member.phone
        idCardTF.text = member.idCard
    }
    

    @IBAction func saveAction(_ sender: Any) {
        member.userName = userNameTF.text
        member.phone = phoneTF.text
        member.idCard = idCardTF.text
        addFellow?(member, isEdit)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
