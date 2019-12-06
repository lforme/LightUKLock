//
//  SelectPopupView.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa

class SelectPopupView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indexOneButton: UIButton!
    @IBOutlet weak var indexTwoButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bind()
    }

    private func bind() {
        indexTwoButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.indexTwoButton.isSelected = true
            self?.indexOneButton.isSelected = false
        }).disposed(by: rx.disposeBag)
        
        indexOneButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.indexTwoButton.isSelected = false
            self?.indexOneButton.isSelected = true
        }).disposed(by: rx.disposeBag)
    }
    
    private func setupUI() {
        layoutIfNeeded()
        self.setCircular(radius: 5)
        
        cancelButton.setCircular(radius: cancelButton.bounds.height / 2)
        confirmButton.setCircular(radius: confirmButton.bounds.height / 2)
        
        cancelButton.layer.borderColor = ColorClassification.textPlaceholder.value.cgColor
        cancelButton.layer.borderWidth = 1
        
        indexTwoButton.setImage(UIImage(named: "home_lock_radio_select"), for: .selected)
        indexOneButton.setImage(UIImage(named: "home_lock_radio_select"), for: .selected)
        
        indexOneButton.tag = 0
        indexTwoButton.tag = 1
    }
}
