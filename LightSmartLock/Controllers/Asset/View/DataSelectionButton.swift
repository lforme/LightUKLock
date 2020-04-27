//
//  DataSelectionButton.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class DataSelectionButton: UIButton {
    
    var items: [String] = ["1", "2", "3"]
    var selectedIndex: Int?
    var title: String? = "请选择"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(title, for: .normal)
        rx.tap
            .asObservable()
            .flatMapFirst { [unowned self]_ -> Observable<Int> in
                guard !self.items.isEmpty else {
                    return .empty()
                }
                var initialItem: (Int, Int)?
                if let selectedIndex = self.selectedIndex {
                    initialItem = (0, selectedIndex)
                }
                return DataPickerViewController.rx
                    .show(values: [self.items], initialSelection: initialItem)
                    .map { $0?.row }
                    .asObservable()
                    .filterNil()
        }
        .subscribe(onNext: { [weak self](index) in
            self?.selectedIndex = index
            self?.setTitle(self?.items[index], for: .normal)
        })
            .disposed(by: rx.disposeBag)
        
        
    }
    
}


