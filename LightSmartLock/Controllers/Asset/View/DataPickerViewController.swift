//
//  DataPickerViewController.swift
//  AptsSteward
//
//  Created by changjun on 2019/11/21.
//  Copyright © 2019 UOKO. All rights reserved.
//

import UIKit
import RxSwift

extension UIAlertController {
    
    /// Add a picker view
    ///
    /// - Parameters:
    ///   - values: values for picker view
    ///   - initialSelection: initial selection of picker view
    ///   - action: action for selected value of picker view
    func addPickerView(values: DataPickerViewController.Values,  initialSelection: DataPickerViewController.Index? = nil, action: DataPickerViewController.Action?) {
        let pickerView = DataPickerViewController(values: values, initialSelection: initialSelection, action: action)
        let vc = UINavigationController(rootViewController: pickerView)
        set(vc: vc, height: 200)
    }
}

final class DataPickerViewController: UIViewController {
    
    public typealias Values = [[String]]
    public typealias Index = (column: Int, row: Int)
    public typealias Action = (Index?) -> ()
    
    fileprivate var action: Action?
    fileprivate var values: Values = [[]]
    fileprivate var initialSelection: Index?
    fileprivate var selectedIndex: Index?
    
    fileprivate lazy var pickerView: UIPickerView = {
        return $0
    }(UIPickerView())
    
    init(values: Values, initialSelection: Index? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        self.values = values
        self.initialSelection = initialSelection
        self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = pickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        navigationItem.title = "请选择时间段"
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelAction))
        let confirmBtn = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirmAction))
        navigationItem.leftBarButtonItem = cancelBtn
        navigationItem.rightBarButtonItem = confirmBtn
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmAction() {
        action?(self.selectedIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let initialSelection = initialSelection, values.count > initialSelection.column, values[initialSelection.column].count > initialSelection.row {
            pickerView.selectRow(initialSelection.row, inComponent: initialSelection.column, animated: true)
        }
    }
}

extension DataPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return values.count
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values[component].count
    }
    /*
     // returns width of column and height of row for each component.
     public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
     
     }
     
     public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
     
     }
     */
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[component][row]
    }
    /*
     public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
     // attributed title is favored if both methods are implemented
     }
     
     
     public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
     
     }
     */
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = Index(column: component, row: row)
    }
}


extension Reactive where Base: DataPickerViewController {
    static func show(values: DataPickerViewController.Values,  initialSelection: DataPickerViewController.Index?) -> Single<DataPickerViewController.Index?> {
        return Single<DataPickerViewController.Index?>.create { event in
            let alert = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)
            
            alert.addPickerView(values: values, initialSelection: initialSelection) { (index) in
                event(.success(index))
            }
            
            let disposable = alert.rx.methodInvoked(#selector(UIAlertController.viewWillDisappear(_:)))
                .subscribe(onNext: { n in
                    event(.success(nil))
                })
            
            alert.show()
            return Disposables.create([disposable])
        }
    }
}
