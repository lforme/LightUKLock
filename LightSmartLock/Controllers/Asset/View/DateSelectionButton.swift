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
    var maxDate: Date?
    var minDate: Date?
    var selectedDateStr: String? {
        didSet {
            self.setTitle(selectedDateStr, for: .normal)
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
            .flatMapFirst { [unowned self]_ -> Observable<String> in
                return DatePickerController.rx.present(with: "yyyy-MM-dd", mode: .date, maxDate: self.maxDate, miniDate: self.minDate)
        }
        .subscribe(onNext: { [weak self]selectedDateStr in
            self?.selectedDateStr = selectedDateStr
        })
            .disposed(by: rx.disposeBag)
    }
}
