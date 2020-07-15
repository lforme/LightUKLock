//
//  LiquidationViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class LiquidationViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var liquidationWayLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    private let liquidationWays = ["银行转账": 1, "微信账号": 2, "支付宝账号": 3, "POS机": 4, "其他": 999]
    
    var billId: String?
    var contractId = ""
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "清算退租"
        setupTaps()
        bind()
    }
    
    func bind() {
        self.dateLabel.text = Date().toFormat("yyyy-MM-dd")
        self.liquidationWayLabel.text = liquidationWays.keys.reversed().first
        
        let confirmAction = Action<(), Bool> {[unowned self] (_) -> Observable<Bool> in
            
            if self.dateLabel.text.isNilOrEmpty {
                return .error(AppError.reason("请选择时间"))
            } else if self.liquidationWayLabel.text.isNilOrEmpty {
                return .error(AppError.reason("请选择清算方式"))
            } else {
                return BusinessAPI.requestMapBool(.terminationContract(contractId: self.contractId, billId: self.billId, accountType: self.liquidationWays[self.liquidationWayLabel.text!]!, clearDate: self.dateLabel.text!))
            }
        }
        
        confirmButton.rx.bind(to: confirmAction, input: ())
        
        confirmAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        confirmAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                HUD.flash(.label("退租成功"), delay: 2)
                
                guard let tagerVC = self?.navigationController?.children.filter({ (vc) -> Bool in
                    return vc is AssetDetailViewController
                }).last else { return }
                
                NotificationCenter.default.post(name: .refreshAssetDetail, object: nil)
                
                self?.navigationController?.popToViewController(tagerVC, animated: true)
    
            } else {
                HUD.flash(.label("退租失败"), delay: 2)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupTaps() {
        let dateTap = UITapGestureRecognizer(target: self, action: #selector(LiquidationViewController.pickDateTap))
        self.dateLabel.addGestureRecognizer(dateTap)
        
        let waysTap = UITapGestureRecognizer(target: self, action: #selector(LiquidationViewController.pickWayTap))
        self.liquidationWayLabel.addGestureRecognizer(waysTap)
    }
    
    @objc func pickWayTap() {
        
        DataPickerController.rx.present(with: "选择清算方式", items: [liquidationWays.keys.reversed()]).map { $0.last?.value }.bind(to: liquidationWayLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    @objc func pickDateTap() {
        
        DatePickerController.rx.present(with: "yyyy-MM-dd", mode: .date, maxDate: nil, miniDate: nil).bind(to: dateLabel.rx.text).disposed(by: rx.disposeBag)
    }
}
