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
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var propertyButton: UIButton!
    
    
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        [propertyButton, messageButton, userButton, keyButton].forEach { (btn) in
            btn?.layer.setValue(true, forKey: "continuousCorners")
            btn?.layer.cornerRadius = 3
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        }
    }
}
