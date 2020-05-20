//
//  DateCyclePickerController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/19.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import Then

class DateCyclePickerController: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var startDateView: UIDatePicker!
    @IBOutlet weak var endDateView: UIDatePicker!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate let formatter = DateFormatter()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadViewIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewIfNeeded()
    }
    
    deinit {
        print(self)
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
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            self.containerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: containerHeight)
            
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        startDateView.locale = Locale(identifier: "zh_CN")
        endDateView.locale = Locale(identifier: "zh_CN")
        containerView.setCircular(radius: 7)
    }
}

extension Reactive where Base: DateCyclePickerController {
    
    static func present() -> Observable<(String, String)> {
        
        return Observable<(String, String)>.create { (observer) -> Disposable in
            
            let pickerVC = DateCyclePickerController().then { (vc) in
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                
                let dismissAction = CocoaAction {
                    observer.onCompleted()
                    return .empty()
                }
                
                vc.cancelButton.rx.action = dismissAction
                vc.dismissButton.rx.action = dismissAction
                
                vc.confirmButton.rx.action = CocoaAction { [unowned vc] in
                    var startDate = Date().toFormat("yyyy-MM-dd")
                    var endDate = Date().toFormat("yyyy-MM-dd")
                    
                    vc.startDateView.rx.value.subscribe(onNext: { (date) in
                        let dateString = vc.formatter.string(from: date)
                        startDate = dateString
                    }).disposed(by: vc.rx.disposeBag)
                    
                    vc.endDateView.rx.value.subscribe(onNext: { (date) in
                        let dateString = vc.formatter.string(from: date)
                        endDate = dateString
                    }).disposed(by: vc.rx.disposeBag)
                    
                    observer.onNext((startDate, endDate))
                    observer.onCompleted()
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
        }
    }
}
