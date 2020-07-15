//
//  AddOrEditController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/18.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class AddOrEditController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    enum Kind {
        case add
        case edit
    }
    
    var kind: Kind = .add
    var steward: HouseKeeperModel? = HouseKeeperModel()
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    
    func bind() {
        
        if let value = steward {
            avatarButton.setUrl(value.avatar)
            nameTextField.text = value.username
            companyTextField.text = value.company
            phoneTextField.text = value.phone
            remarkTextField.text = value.remark
        }
        
        nameTextField.rx
            .text
            .orEmpty
            .changed
            .subscribe(onNext: {[weak self] (name) in
                self?.steward?.username = name
            })
            .disposed(by: rx.disposeBag)
        
        companyTextField.rx
            .text
            .orEmpty
            .changed
            .subscribe(onNext: {[weak self] (company) in
                self?.steward?.company = company
            })
            .disposed(by: rx.disposeBag)
        
        phoneTextField.rx
            .text
            .orEmpty
            .changed
            .subscribe(onNext: {[weak self] (phone) in
                self?.steward?.phone = phone
            })
            .disposed(by: rx.disposeBag)
        
        remarkTextField.rx
            .text
            .orEmpty
            .changed
            .subscribe(onNext: {[weak self] (remark) in
                self?.steward?.remark = remark
            })
            .disposed(by: rx.disposeBag)
        
        avatarButton.rx.tap.flatMapLatest { (_) -> Observable<UIImage> in
            
            return ImagePicker.present(maxImageCount: 1).map { $0.first ?? UIImage() }
        }.flatMapLatest {[weak self] (image) -> Observable<String?> in
            self?.avatarButton.setImage(image, for: UIControl.State())
            
            return BusinessAPI.requestMapAny(.uploadImage(image, description: "管家头像")).map { (res) -> String? in
                let json = res as? [String: Any]
                let headPicUrl = json?["data"] as? String
                return headPicUrl
            }
        }.subscribe(onNext: {[weak self] (imageUrl) in
            guard let this = self else { return }
            this.steward?.avatar = imageUrl
            
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        
        createdRightNavigationItem(title: "保存", font: nil, image: nil, rightEdge: 4, color: .white)
            .rx
            .tap
            .flatMapLatest {[unowned self] (_) -> Observable<Bool> in
                switch self.kind {
                    
                case .add:
                    return BusinessAPI.requestMapBool(.addSteward(steward: self.steward!))
                    
                case .edit:
                    
                    return BusinessAPI.requestMapBool(.editSteward(steward: self.steward!))
                }
        }.subscribe(onNext: {[weak self] (success) in
            if success {
                NotificationCenter.default.post(name: .refreshState, object: NotificationRefreshType.steward)
                self?.navigationController?.popViewController(animated: true)
            }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        avatarButton.clipsToBounds = true
        avatarButton.layer.cornerRadius = self.avatarButton.bounds.height / 2
        avatarButton.imageView?.contentMode = .scaleAspectFill
        switch kind {
        case .add:
            title = "新建联系人"
        case .edit:
            title = "编辑联系人"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 8
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
}
