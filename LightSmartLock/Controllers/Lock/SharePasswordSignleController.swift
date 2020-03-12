//
//  SharePasswordSignleController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class SharePasswordSignleController: UITableViewController {
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var MarkTextField: UITextField!
    
    var shareButton: UIButton!
    let vm = SharePwdSingleViewModel()
    
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
    
    func bind() {
        
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
    
    func setupNavigationRightItem() {
        self.shareButton = createdRightNavigationItem(title: "分享", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white)
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
}
