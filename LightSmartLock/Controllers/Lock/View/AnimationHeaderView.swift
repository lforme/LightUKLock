//
//  AnimationHeaderView.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class AnimationHeaderView: UITableViewCell {
    
    private(set) var disposeBag = DisposeBag()
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var powerLabel: UILabel!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.backgroundColor = ColorClassification.blueAndBlack.value
    }
    
    func bind(openStatus: Bool?, onlineStatus: Bool?, power: Double?) {
        guard let online = onlineStatus, let power = power else {
            return
        }
        
        if !online {
            HUD.flash(.label("门锁已离线"), delay: 2)
        }
        
        if power < 0.20 {
            lockImageView.image = UIImage(named: "lock_icon_power_low")
            let powerValue = power * 100
            powerLabel.text = "\(powerValue) %"
        } else {
            lockImageView.image = UIImage(named: "lock_icon_power_normal")
            powerLabel.text = nil
        }
        
    }
}
