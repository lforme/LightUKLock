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
        
        self.bgView.clipsToBounds = true
        self.bgView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
    }
    
    func bind(_ data: SceneListModel) {
        name.text = data.buildingName ?? "-"
        address.text = data.buildingAdress ?? "-"
        
        if data.ladderLockId.isNotNilNotEmpty {
            message.text = data.lockType
            message.alpha = 1.0
            bindLockButton.setImage(UIImage(named: "my_lock_is_bind"), for: UIControl.State())
        } else {
            message.text = "未绑定门锁"
            message.alpha = 0.5
            bindLockButton.setImage(UIImage(named: "my_lock_not_bind"), for: UIControl.State())
        }
        
        if data.ladderLockId.isNilOrEmpty {
            let buildingName = data.buildingName ?? "-"
            name.text = "\(buildingName) (\("待添加门锁"))"
        }
        
        if data.ladderAssetHouseId.isNilOrEmpty {
            name.text = "待绑定资产"
            address.text = nil
        }
        
    }
}
