//
//  DataPickerController.swift
//  IntelligentUOKO
//
//  Created by mugua on 2018/10/30.
//  Copyright © 2018 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import Then
import RxDataSources

typealias PickerResult = (component: Int, row: Int, value: String)
class DataPickerController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var pickView: UIPickerView!
    @IBOutlet weak var containerButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    private let stringPickerAdapter = RxPickerViewStringAdapter<[[String]]>(components: [], numberOfComponents: { (ds, pk, components) -> Int in
        return components.count
    }, numberOfRowsInComponent: { (ds, pk, components, component) -> Int in
        return components[component].count
    }) { (ds, pk, components, row, component) -> String? in
        return components[component][row]
    }
    
    fileprivate convenience init(title: String?, data: [[String]]) {
        self.init()
        loadViewIfNeeded()
        self.titleLabel.text = title
        Observable.just(data).subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: pickView.rx.items(adapter: stringPickerAdapter))
            .disposed(by: rx.disposeBag)
        
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
    }
    
}

extension Reactive where Base: DataPickerController {
    
    static func present(with title: String, items: [[String]]) -> Observable<[PickerResult]> {
        
        return Observable<[PickerResult]>.create { observer in
            let dataPicker = DataPickerController(title: title, data: items)
                .then { vc in
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    
                    let dismissAction = CocoaAction {
                        observer.onNext([])
                        observer.onCompleted()
                        return .empty()
                    }
                    vc.cancelButton.rx.action = dismissAction
                    vc.containerButton.rx.action = dismissAction
                    
                    vc.confirmButton.rx.action = CocoaAction { [unowned vc] in
                        
                        var result: [PickerResult] = []
                        
                        switch items.count {
                        case 1:
                            result.append((0, vc.pickView.selectedRow(inComponent: 0), items[0][vc.pickView.selectedRow(inComponent: 0)]))
                            observer.onNext(result)
                        case 2:
                            result.append((0, vc.pickView.selectedRow(inComponent: 0), items[0][vc.pickView.selectedRow(inComponent: 0)]))
                            result.append((1, vc.pickView.selectedRow(inComponent: 1), items[1][vc.pickView.selectedRow(inComponent: 1)]))
                            observer.onNext(result)
                        case 3:
                            result.append((0, vc.pickView.selectedRow(inComponent: 0), items[0][vc.pickView.selectedRow(inComponent: 0)]))
                            result.append((1, vc.pickView.selectedRow(inComponent: 1), items[1][vc.pickView.selectedRow(inComponent: 1)]))
                            result.append((2, vc.pickView.selectedRow(inComponent: 2), items[2][vc.pickView.selectedRow(inComponent: 2)]))
                            observer.onNext(result)
                            
                        default: break
                        }
                        
                        observer.onCompleted()
                        return .empty()
                    }
            }
            
            if let currentVC = RootViewController.topViewController() {
                currentVC.present(dataPicker, animated: false, completion: nil)
            } else {
                observer.onCompleted()
            }
            
            return Disposables.create {
                dataPicker.dismiss(animated: true, completion: nil)
            }
        }
    }
}
