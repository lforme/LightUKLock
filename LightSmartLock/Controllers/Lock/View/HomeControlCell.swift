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
    
    @IBOutlet weak var housekeeperButton: UIButton!
    @IBOutlet weak var notiButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var pwdButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        [housekeeperButton, notiButton, memberButton, pwdButton].forEach { (btn) in
            btn?.layer.setValue(true, forKey: "continuousCorners")
            btn?.layer.cornerRadius = 3
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        }
    }
}
