//
//  DatePickerController.swift
//  IntelligentUOKO
//
//  Created by mugua on 2019/8/16.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import Then

class DatePickerController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dismissBackgourndView: UIButton!
    
    let formatter = DateFormatter()
    
    deinit {
        print(self)
    }
    
    convenience init(dateFormatString: String, mode: UIDatePicker.Mode = UIDatePicker.Mode.date, locale: Locale?) {
        self.init()
        loadViewIfNeeded()
        formatter.dateFormat = "yyyy"
        titleLabel.text = formatter.string(from: Date())
        datePicker.locale = locale
        formatter.dateFormat = dateFormatString
        datePicker.datePickerMode = mode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let containerHeight = containerView.frame.height
        containerView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: containerHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.containerView.frame = CGRect(x: 0, y: self.view.bounds.height - containerHeight, width: self.view.bounds.width, height: containerHeight)
            
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let containerHeight = containerView.frame.height
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.containerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: containerHeight)
            
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 7
    }
    
}


extension Reactive where Base: DatePickerController {
    
    static func present(with dateFormatString: String, locale: Locale = Locale(identifier: "zh_CN"), mode: UIDatePicker.Mode?, maxDate: Date?, miniDate: Date?) -> Observable<String> {
        
        return Observable<String>.create({ (observer) -> Disposable in
            
            let pickerVC = DatePickerController(dateFormatString: dateFormatString, mode: mode ?? .date, locale: locale).then { (vc) in
                
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                
                vc.datePicker.maximumDate = maxDate
                vc.datePicker.minimumDate = miniDate
                
                let dismissAction = CocoaAction {
                    observer.onCompleted()
                    return .empty()
                }
                vc.cancelButton.rx.action = dismissAction
                vc.dismissBackgourndView.rx.action = dismissAction
                
                vc.confirmButton.rx.action = CocoaAction { [unowned vc] in
                    
                    vc.datePicker.rx.value.subscribe(onNext: { (date) in
                        let dateString = vc.formatter.string(from: date)
                        observer.onNext(dateString)
                        observer.onCompleted()
                    }).disposed(by: vc.rx.disposeBag)
                    return .empty()
                }
            }
            
            if let currentVC = RootViewController.topViewController() {
                currentVC.present(pickerVC, animated: false, completion: nil)
            } else {
                observer.onCompleted()
            }
            
            return Disposables.create {
                pickerVC.dismiss(animated: true, completion: nil)
            }
        })
    }
}
