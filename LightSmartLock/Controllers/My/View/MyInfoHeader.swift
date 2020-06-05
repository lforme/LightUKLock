//
//  MyInfoHeader.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift

class MyInfoHeader: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nick: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var avatarGestureTap: UITapGestureRecognizer!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = ColorClassification.tableViewBackground.value
        
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatar.bounds.height / 2
    
        avatarGestureTap = UITapGestureRecognizer(target: nil, action: nil)
        avatar.addGestureRecognizer(avatarGestureTap)
    }
}
