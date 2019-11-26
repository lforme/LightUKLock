//
//  HomeControlCell.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeControlCell: UITableViewCell {
    
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = ColorClassification.viewBackground.value
        
        keyButton.set(image: UIImage(named: "manage_key"), title: "密码管理", titlePosition: .bottom, additionalSpacing: 20, state: UIControl.State())
        fingerButton.set(image: UIImage(named: "manage_finger"), title: "指纹管理", titlePosition: .bottom, additionalSpacing: 20, state: UIControl.State())
        cardButton.set(image: UIImage(named: "card_manage"), title: "门卡管理", titlePosition: .bottom, additionalSpacing: 20, state: UIControl.State())
        userButton.set(image: UIImage(named: "user_manage"), title: "用户管理", titlePosition: .bottom, additionalSpacing: 20, state: UIControl.State())
        
        [keyButton, fingerButton, cardButton, userButton].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.textDescription.value, for: .normal)
        }
    }
    
    
}
