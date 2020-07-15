//
//  PayWayBindController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class PayWayBindController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var qrLabel: UILabel!
    @IBOutlet weak var pickQrButton: UIButton!
    @IBOutlet weak var defaultSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    var originModel: CollectionAccountModel?
    let obModel = BehaviorRelay<CollectionAccountModel>(value: CollectionAccountModel())
    
    enum PayWay {
        case wechat
        case ali
    }
    
    var canEditing: Bool = false
    var isDisplayMode: Bool = false
    var payWay: PayWay = .wechat
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        setupNavigationRightItem()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        pickQrButton.imageView?.contentMode = .scaleAspectFit
        
        if isDisplayMode {
            saveButton.isHidden = true
            defaultSwitch.isUserInteractionEnabled = false
            nameTextField.isEnabled = false
            accountTextField.isEnabled = false
            copyButton.isHidden = false
        }
    }
    
    func setupNavigationRightItem() {
        if canEditing {
            createdRightNavigationItem(title: "删除", font: nil, image: nil, rightEdge: 0, color: UIColor.white)
        }
    }
    
    func bind() {
        let oldValue = self.obModel.value
        
        switch payWay {
        case .ali:
            title = "绑定支付宝支付"
            nameLabel.text = "真实姓名"
            nameTextField.placeholder = "请输入真实姓名"
            accountLabel.text = "支付宝账号"
            accountTextField.placeholder = "请输入支付宝账号"
            qrLabel.text = "支付宝收款码"
            oldValue.accountType = 3
        case .wechat:
            title = "绑定微信支付"
            nameLabel.text = "微信昵称"
            nameTextField.placeholder = "请输入微信昵称"
            accountLabel.text = "微信账号"
            accountTextField.placeholder = "请输入微信账号"
            qrLabel.text = "微信收款码"
            oldValue.accountType = 2
        }
        
        if let oldModel = originModel {
            nameTextField.text = oldModel.userName
            accountTextField.text = oldModel.account
            pickQrButton.setUrl(oldModel.paymentCodeUrl)
            defaultSwitch.isOn = oldModel.isDefault ?? false
        }
        
        nameTextField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.userName = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        accountTextField.rx.text.orEmpty.changed
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (value) in
                let temp = self.obModel.value
                temp.account = value
                self.obModel.accept(temp)
            }).disposed(by: rx.disposeBag)
        
        defaultSwitch.rx.value.subscribe(onNext: {[unowned self] (isOn) in
            let temp = self.obModel.value
            temp.isDefault = isOn
            self.obModel.accept(temp)
        }).disposed(by: rx.disposeBag)
        
        let saveAction = Action<(), Bool> {[weak self] (_) -> Observable<Bool> in
            guard let this = self else {
                return .error(AppError.reason("发生未知错误"))
            }
            
            let model = this.obModel.value
            if model.account.isNilOrEmpty {
                return .error(AppError.reason("请填账号"))
            } else if model.userName.isNilOrEmpty {
                return .error(AppError.reason("请填昵称"))
            } else if model.paymentCodeUrl.isNilOrEmpty {
                return .error(AppError.reason("请选择付款二维码"))
            } else {
                
                return BusinessAPI.requestMapBool(.addReceivingAccount(parameter: model))
            }
        }
        
        saveButton.rx.bind(to: saveAction, input: ())
        
        saveAction.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        saveAction.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.accountWay)
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
        
        // 显示模式
        if isDisplayMode {
            pickQrButton.rx.tap.flatMapLatest {[unowned self] in
                self.showActionSheet(title: "保存到相册", message: nil, buttonTitles: ["保存", "取消"], highlightedButtonIndex: 1)
            }.subscribe(onNext: {[weak self] (buttonIndex) in
                if buttonIndex == 0 {
                    guard let saveImage = self?.pickQrButton.imageView?.image else {
                        return
                    }
                    
                    UIImageWriteToSavedPhotosAlbum(saveImage, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }).disposed(by: rx.disposeBag)
        } else {
            // 非显示模式
            pickQrButton.rx.tap.flatMapLatest { (_) -> Observable<UIImage> in
                
                return ImagePicker.present(maxImageCount: 1).map { $0.first ?? UIImage() }
            }.flatMapLatest {[weak self] (image) -> Observable<String?> in
                self?.pickQrButton.setImage(image, for: UIControl.State())
                
                return BusinessAPI.requestMapAny(.uploadImage(image, description: "支付二维码")).map { (res) -> String? in
                    let json = res as? [String: Any]
                    let headPicUrl = json?["data"] as? String
                    return headPicUrl
                }
            }.subscribe(onNext: {[weak self] (imageUrl) in
                guard let this = self else { return }
                let temp = this.obModel.value
                temp.paymentCodeUrl = imageUrl
                this.obModel.accept(temp)
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 80
        }
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    @IBAction func copyButtonTap(_ sender: UIButton) {
        guard let copyString = accountTextField.text else {
            return
        }
        UIPasteboard.general.string = copyString
        HUD.flash(.label("复制成功"), delay: 2)
    }
}

extension PayWayBindController {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            HUD.flash(.label("保存成功"), delay: 2)
        } else {
            PKHUD.sharedHUD.rx.showError(error)
        }
    }
}
