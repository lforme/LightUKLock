//
//  AddUserController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import TZImagePickerController
import RxCocoa
import RxSwift

class AddUserController: UITableViewController {
    
    enum SelectType: Int {
        case avatar = 0
        case nickname
        case phone
        case userTag
        case password = 10
    }
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var phonTextField: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var bluetoothWayButton: UIButton!
    @IBOutlet weak var remoteWayButton: UIButton!
    
    var saveButton: UIButton!
    
    var vm: AddUserViewModel!
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "添加用户"
        setupUI()
        setupNavigationRightItem()
        bind()
    }
    
    func setupNavigationRightItem() {
        self.saveButton = createdRightNavigationItem(title: "保存", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 4, color: .white)
    }
    
    func bind() {
        guard let sceneId = LSLUser.current().userInScene?.sceneID else {
            HUD.flash(.label("无法从服务器获取用户场景, 请稍后再试"), delay: 2)
            return
        }
        self.vm = AddUserViewModel(id: sceneId)
        
        nicknameTextField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: vm.nickname).disposed(by: rx.disposeBag)
        
        phonTextField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: vm.phone).disposed(by: rx.disposeBag)
        
        
        vm.displayModel.subscribe(onNext: {[weak self] (display) in
            
            if let tag = display.Label {
                self?.tagLabel.text = tag
                self?.tagLabel.textColor = ColorClassification.textPrimary.value
            } else {
                self?.tagLabel.textColor = ColorClassification.textDescription.value
            }
            
            if let pwd = display.InitialSecret {
                self?.passwordLabel.text = pwd
            }
            
        }).disposed(by: rx.disposeBag)
        
        saveButton.rx.bind(to: vm.saveAtion, input: AddUserMemberModel())
        
        vm.saveAtion.errors.subscribe(onNext: { (error) in
            PKHUD.sharedHUD.rx.showActionError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.saveAtion.elements.subscribe(onNext: {[weak self] (success) in
            if success {
                HUD.flash(.label("添加成功"), delay: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        avatar.setCircular(radius: avatar.bounds.height / 2)
        
        [bluetoothWayButton, remoteWayButton].forEach { (btn) in
            btn?.setCircular(radius: 2)
            btn?.setTitleColor(UIColor.white, for: .selected)
            btn?.setBackgroundImage(UIImage(color: ColorClassification.primary.value, size: btn!.bounds.size), for: .selected)
            btn?.setBackgroundImage(UIImage(color: ColorClassification.textDescription.value, size: btn!.bounds.size), for: .normal)
        }
        
        bluetoothWayButton.isSelected = true
    }
    
    @IBAction func bluetoothWayTap(_ sender: UIButton) {
        sender.isSelected = true
        remoteWayButton.isSelected = false
        vm.addWay = .bluetooth
        vm.setAddWay(0)
    }
    
    @IBAction func remoteWayTap(_ sender: UIButton) {
        sender.isSelected = true
        bluetoothWayButton.isSelected = false
        vm.addWay = .remote
        vm.setAddWay(1)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = SelectType(rawValue: indexPath.row + indexPath.section * 10) else {
            return
        }
        
        switch type {
        case .avatar:
            let imagePickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
            imagePickerVC?.needCircleCrop = true
            imagePickerVC?.didFinishPickingPhotosHandle = {[weak self] (photos, _, _)in
                guard let this = self else {
                    return
                }
                if let image = photos?.first {
                    this.avatar.image = image
                    this.vm.pickUserAvatar(image)
                }
            }
            navigationController?.present(imagePickerVC!, animated: true, completion: nil)
            
        case .nickname:
            break
        case .phone:
            break
        case .userTag:
            vm.userTags.flatMapFirst { (tags) -> Observable<String?> in
                return DataPickerController.rx.present(with: "选择成员标签", items: [tags]).map { (result) -> String? in
                    return result.last?.value
                }
            }.subscribe(onNext: {[weak self] (tag) in
                self?.vm.setTag(tag ?? "")
            }).disposed(by: rx.disposeBag)
            
        case .password:
            vm.setPassword()
        }
    }
}

extension AddUserController: TZImagePickerControllerDelegate {}
