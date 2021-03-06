//
//  AddTenantFellowViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import HandyJSON
import PKHUD

class TenantMember: HandyJSON {
    var id: String?
    var idCard: String?
    var idCardFront: String?
    var idCardReverse: String?
    var phone: String?
    var userName: String?
    
    required init() {
        
    }
}

class AddTenantFellowViewController: AssetBaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var idCardTF: UITextField!
    
    @IBOutlet weak var idCardFrontView: IDCardView!
    
    @IBOutlet weak var idCardReverseView: IDCardView!
    
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
        
        idCardFrontView.placeImage = #imageLiteral(resourceName: "id_front")
        idCardReverseView.placeImage = #imageLiteral(resourceName: "id_back")
        
        idCardFrontView.isFront = true
        idCardReverseView.isFront = false

        idCardFrontView.updateIDCard = { [weak self] id in
            self?.idCardTF.text = id
        }
        
        idCardReverseView.updateIDCard = { [weak self] id in
            self?.idCardTF.text = id
        }
    }
    

    @IBAction func saveAction(_ sender: Any) {
        member.userName = userNameTF.text
        member.phone = phoneTF.text
        member.idCard = idCardTF.text
        member.idCardFront = idCardFrontView.urlStr
        member.idCardReverse = idCardReverseView.urlStr
        if member.userName == nil || member.userName?.isEmpty == true {
            HUD.flash(.label("请填写同住人姓名"))
            return
        }
        if member.phone == nil || member.phone?.count != 11 {
            HUD.flash(.label("请填写同住人手机号"))
            return
        }
        addFellow?(member, isEdit)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
