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

class AnimationHeaderView: UITableViewCell {
    
    private(set) var disposeBag = DisposeBag()
    @IBOutlet weak var lockImageView: UIImageView!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    private let timer = Observable<Int>.timer(1, period: 3, scheduler: MainScheduler.instance)
    private var count = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = ColorClassification.viewBackground.value
    }
        
    func bind(_ data: IOTLockInfoModel?) {
        guard let model = data else {
            return
        }
       
        if let power = model.PowerPercent {
            if power < 0.20 {
                lockImageView.image = UIImage(named: "lock_icon_power_low")
            } else {
                lockImageView.image = UIImage(named: "lock_icon_power_normal")
            }
        }
    }
}
