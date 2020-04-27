//
//  DateSelectionButton.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DateSelectionButton: UIButton {
    
    var title: String = "请选择日期"
    var selectedDate: Date? {
        didSet {
            let dateStr = selectedDate?.toFormat("yyyy-MM-dd")
            self.setTitle(dateStr, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(title, for: .normal)
//        rx.tap
//            .asObservable()
//            .flatMapFirst { [unowned self]_ -> Observable<Date> in
//                return DatePickerViewController.rx.show(date: self.selectedDate, min: nil, max: nil, mode: .date)
//                    .asObservable()
//                    .filterNil()
//        }
//        .subscribe(onNext: { [weak self](date) in
//            self?.selectedDate = date
//        })
//            .disposed(by: rx.disposeBag)
        rx.tap
            .asObservable()
            .flatMapFirst { [unowned self]_ -> Observable<Date> in
                return DatePickerViewController.rx.show(date: self.selectedDate, min: nil, max: nil, mode: .date)
                    .asObservable()
                    .filterNil()
        }
        .subscribe(onNext: { [weak self](date) in
            self?.selectedDate = date
        })
            .disposed(by: rx.disposeBag)
    }
}
