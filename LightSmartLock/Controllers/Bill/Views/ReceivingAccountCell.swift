//
//  ReceivingAccountCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ReceivingAccountCell: UITableViewCell {

    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
