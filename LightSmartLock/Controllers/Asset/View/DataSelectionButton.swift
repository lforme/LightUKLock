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
    
    var items: [[String]] = [[]]
    
    var result: [PickerResult]?  {
        didSet {
            guard let result = result, !result.isEmpty else {
                return
            }
            let str = result.compactMap({ (r) -> String? in
                return r.value
            }).reduce("", { (next, acc) -> String in
                return next + acc
            })
            self.resultStr = str
        }
    }
    
    var resultStr: String? {
        didSet {
            self.setTitle(resultStr, for: .normal)
        }
    }
    
    var title: String = "请选择" {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rx.tap
            .asObservable()
            .flatMapFirst { [unowned self]_ -> Observable<[PickerResult]> in
                return DataPickerController.rx.present(with: self.title, items: self.items)
        }
        .subscribe(onNext: { [weak self](result) in
            self?.result = result
        })
            .disposed(by: rx.disposeBag)
        
        
    }
    
}


