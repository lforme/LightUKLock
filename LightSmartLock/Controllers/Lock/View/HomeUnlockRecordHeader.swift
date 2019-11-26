//
//  HomeUnlockRecordHeader.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeUnlockRecordHeader: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkMoreButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = ColorClassification.textOpaque78.value
        checkMoreButton.setTitleColor(ColorClassification.textDescription.value, for: .normal)
        contentView.backgroundColor = ColorClassification.tableViewBackground.value
        self.backgroundColor = ColorClassification.tableViewBackground.value
    }

}
