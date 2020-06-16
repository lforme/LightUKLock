//
//  MyListCell.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift

class MyListCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bindLockButton: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = true
        self.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
    }
    
    func bind(_ data: SceneListModel) {
        name.text = data.buildingName ?? "-"
        address.text = data.buildingAdress ?? "-"
        
        if let lockInfo = data.lockType, lockInfo.isNotEmpty {
            message.text = "已绑定门锁"
            bindLockButton.setImage(UIImage(named: "my_lock_is_bind"), for: UIControl.State())
        } else {
            message.text = "未绑定门锁"
            bindLockButton.setImage(UIImage(named: "my_lock_not_bind"), for: UIControl.State())
        }
    }
}
