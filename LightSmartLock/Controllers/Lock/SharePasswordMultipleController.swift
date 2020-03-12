//
//  SharePasswordMultipleController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class SharePasswordMultipleController: UITableViewController {
    
    enum SelectType: Int {
        case startTime = 0
        case endTime
    }
    
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var MarkTextField: UITextField!
    @IBOutlet weak var messageButton: UIButton!
    
    let vm = SharePwdMultipleViewModel()
    var shareButton: UIButton!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "发送密码"
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func setupNavigationRightItem() {
        self.shareButton = createdRightNavigationItem(title: "分享", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white)
    }
    
    func bind() {
        vm.displayStartTime.bind(to: startTime.rx.text).disposed(by: rx.disposeBag)
        vm.displayEndTime.bind(to: endTime.rx.text).disposed(by: rx.disposeBag)
        
        vm.displayShareType.subscribe(onNext: {[weak self] (type) in
            switch type {
            case .message:
                self?.messageButton.isSelected = true
            case .qq: break
            case .weixin: break
            }
        }).disposed(by: rx.disposeBag)
        
        messageButton.rx.tap.map { _ in TempPasswordShareType.message }.bind(to: vm.bindShareType).disposed(by: rx.disposeBag)
        
        phoneTextField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: vm.bindPhone).disposed(by: rx.disposeBag)
        
        MarkTextField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: vm.bindMark).disposed(by: rx.disposeBag)
        
        shareButton.rx.bind(to: vm.shareAction, input: TempPasswordShareParameter())
        vm.shareAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.shareAction.elements.subscribe(onNext: {[weak self] (shareBody) in
            print(shareBody)
            HUD.flash(.label("分享成功"), delay: 2)
            self?.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        messageButton.setCircular(radius: 3)
        messageButton.setBackgroundImage(UIImage(color: ColorClassification.primary.value, size: messageButton.bounds.size), for: .selected)
        messageButton.isSelected = true
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            guard let type = SelectType(rawValue: indexPath.row) else {
                return
            }
            switch type {
            case .startTime:
                DatePickerController.rx.present(with: "yyyy-MM-dd 00:00:00", mode: .date, maxDate: nil, miniDate: Date()).bind(to: vm.bindStartTime).disposed(by: rx.disposeBag)
                
            case .endTime:
                DatePickerController.rx.present(with: "yyyy-MM-dd 23:59:59", mode: .date, maxDate: nil, miniDate: self.vm.bindStartTime.value?.toDate()?.date ?? Date()).bind(to: vm.bindEndTime).disposed(by: rx.disposeBag)
            }
        }
    }
    
}
