//
//  LeasedCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/2/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LeasedCell: UITableViewCell {
    
    @IBOutlet weak var unlocker: UILabel!
    @IBOutlet weak var unlockTime: UILabel!
    @IBOutlet weak var assetAddress: UILabel!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var tenantContainer: UIControl!
    
    private(set) var recordBlack: (() -> Void)?
    private(set) var propertyBlock: (() -> Void)?
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        tenantContainer.addTarget(self, action: #selector(propertyTap(_:)), for: .touchUpInside)
        
    }
    
    func bind(unlocker: String?, lastUnlockTime: String?) {
        self.unlocker.text = unlocker
        if let time = lastUnlockTime {
            self.unlockTime.text = "最近开门 \(time)"
        }
    }
    
    @IBAction private func recordTap(_ sender: UIButton) {
        self.recordBlack?()
    }
    
    @objc private func propertyTap(_ sender: UIButton) {
        self.propertyBlock?()
    }
    
    func recordDidSelected(tap: @escaping () -> Void) {
        self.recordBlack = tap
    }
    
    func propertyDidSelected(tap: @escaping () -> Void) {
        self.propertyBlock = tap
    }
    
}
