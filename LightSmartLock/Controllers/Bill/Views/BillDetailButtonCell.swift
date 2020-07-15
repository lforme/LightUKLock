//
//  BillDetailButtonCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxSwift

class BillDetailButtonCell: UICollectionViewCell {

    @IBOutlet weak var rushRentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cornerRadius = 7
    }

}
