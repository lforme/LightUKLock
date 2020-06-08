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
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var qqButton: UIButton!
    @IBOutlet weak var phoneCell: UITableViewCell!
    
    var vm: SharePwdMultipleViewModel!
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
        
        guard let lockId = LSLUser.current().scene?.ladderLockId else {
            HUD.flash(.label("无法获取门锁编号"), delay: 2)
            return
        }
        
        self.vm = SharePwdMultipleViewModel(lockId: lockId)
        
        vm.displayStartTime.bind(to: startTime.rx.text).disposed(by: rx.disposeBag)
        vm.displayEndTime.bind(to: endTime.rx.text).disposed(by: rx.disposeBag)
        
        vm.displayShareType.subscribe(onNext: {[weak self] (type) in
            switch type {
            case .message:
                self?.messageButton.isSelected = true
                self?.wechatButton.isSelected = false
                self?.qqButton.isSelected = false
                self?.phoneCell.isHidden = false
                
            case .qq:
                self?.messageButton.isSelected = false
                self?.wechatButton.isSelected = false
                self?.qqButton.isSelected = true
                self?.phoneCell.isHidden = true
                
            case .weixin:
                self?.messageButton.isSelected = false
                self?.wechatButton.isSelected = true
                self?.qqButton.isSelected = false
                self?.phoneCell.isHidden = true
            }
        }).disposed(by: rx.disposeBag)
        
        messageButton.rx
            .tap
            .map {_ in
                return TempPasswordShareWayType.message }
            .bind(to: vm.bindShareType)
            .disposed(by: rx.disposeBag)
        
        wechatButton.rx
            .tap
            .map { _ in
                return TempPasswordShareWayType.weixin }
            .bind(to: vm.bindShareType)
            .disposed(by: rx.disposeBag)
        
        qqButton.rx
            .tap
            .map { _ in
                return TempPasswordShareWayType.qq }
            .bind(to: vm.bindShareType)
            .disposed(by: rx.disposeBag)
        
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
            switch self?.vm.bindShareType.value {
            case .message:
                HUD.flash(.label("分享成功"), delay: 2)
                
            case .weixin:
                ShareTool.share(platform: .weixin, contentText: shareBody.content, url: ServerHost.shared.environment.host + (shareBody.url ?? ""), title: shareBody.title) { (success) in
                    if success {
                        HUD.flash(.label("分享成功"), delay: 2)
                    }
                }
                
            case .qq:
                ShareTool.share(platform: .qq, contentText: shareBody.content, url: ServerHost.shared.environment.host + (shareBody.url ?? ""), title: shareBody.title) { (success) in
                    if success {
                        HUD.flash(.label("分享成功"), delay: 2)
                    }
                }
            default: break
            }
            
            self?.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.tempPassword)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        
        [messageButton, wechatButton, qqButton].forEach { (btn) in
            btn?.setCircular(radius: 7)
            btn?.clipsToBounds = true
            btn?.setBackgroundImage(UIImage(color: ColorClassification.primary.value, size: btn!.bounds.size), for: .selected)
            btn?.isSelected = true
            btn?.setTitleColor(.white, for: .selected)
        }
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
