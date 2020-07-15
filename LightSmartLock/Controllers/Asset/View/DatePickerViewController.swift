import UIKit
import RxSwift

func alert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
    alert.show()
}

extension UIViewController {
    func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
        }
    }
    
    func pushed(animated: Bool = true) {
        
        DispatchQueue.main.async {
            (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.pushViewController(self, animated: animated)
        }
    }
    
    func poped(animated: Bool = true) {
        
        DispatchQueue.main.async {
            (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.popViewController(animated: animated)
        }
    }
}

extension UIAlertController {
    
    func set(vc: UIViewController, height: CGFloat) {
        vc.preferredContentSize.height = height
        setValue(vc, forKey: "contentViewController")
    }
    
    /// Add a date picker
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    ///   - date: selected date of date picker
    ///   - minimumDate: minimum date of date picker
    ///   - maximumDate: maximum date of date picker
    ///   - action: an action for datePicker value change
    
    func addDatePicker(mode: UIDatePicker.Mode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerViewController.Action?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
        let vc = UINavigationController(rootViewController: datePicker)
        set(vc: vc, height: 200)
    }
}

final class DatePickerViewController: UIViewController {
    
    public typealias Action = (Date) -> Void
    
    fileprivate var action: Action?
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "zh_CN")
        return picker
    }()
    
    required init(mode: UIDatePicker.Mode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = datePicker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择日期"
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelAction))
        let confirmBtn = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirmAction))
        navigationItem.leftBarButtonItem = cancelBtn
        navigationItem.rightBarButtonItem = confirmBtn
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmAction() {
        action?(datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}

extension Reactive where Base: DatePickerViewController {
    static func show(date: Date? = Date(),
                     min: Date? = nil,
                     max: Date? = nil,
                     mode: UIDatePicker.Mode = UIDatePicker.Mode.date) -> Single<Date?> {
        return Single<Date?>.create { event in
            let alert = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)
            
            alert.addDatePicker(mode: .date,
                                date: date,
                                minimumDate: min,
                                maximumDate: max) { newDate in
                                    event(.success(newDate))
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
