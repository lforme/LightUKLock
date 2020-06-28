//
//  MoreAssetCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/24.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MoreAssetCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var bindButton: UIButton!
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
