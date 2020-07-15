//
//  BillFlowCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BillFlowCell: UICollectionViewCell {

    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var inPrice: UILabel!
    @IBOutlet weak var outPrice: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var expenedButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        month.setCircular(radius: 7)
    }

}
