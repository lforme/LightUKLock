//
//  MySettingViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD
import TZImagePickerController

class MySettingViewController: UITableViewController, NavigationSettingStyle {
    
    enum CellType: Int {
        case avatar = 0
        case nickname
        case password
        case phone
        case logout
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.viewBackground.value
    }
    
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    
    let vm = MySettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账户设置"
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.tableView.backgroundColor = ColorClassification.tableViewBackground.value
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.avatar.clipsToBounds = true
        self.avatar.layer.cornerRadius = self.avatar.bounds.height / 2
    }
    
    func bind() {
        let shareInfo = LSLUser.current().obUserInfo.share(replay: 1, scope: .forever)
        shareInfo.map { $0?.userName }.bind(to: nameValue.rx.text).disposed(by: rx.disposeBag)
        shareInfo.map { $0?.headPic }.subscribe(onNext: {[weak self] (str) in
            guard let urlStr = str else { return }
            let newString = urlStr.replacingOccurrences(of: "\\", with: "/")
            self?.avatar.kf.setImage(with: URL(string: newString))
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = CellType(rawValue: indexPath.row) else { return }
        switch type {
        case .avatar:
            uploadAvatarAction()
            
        case .logout:
           logoutAction()
        default:
            break
        }
    }
}

extension MySettingViewController: TZImagePickerControllerDelegate {}

extension MySettingViewController {
    
    func logoutAction() {
        showActionSheet(title: "确定要退出吗?", message: nil, buttonTitles: ["去意已决", "再玩会儿"], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                LSLUser.current().logout()
            }
        }
    }
    
    func uploadAvatarAction() {
        let imagePickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
        imagePickerVC?.needCircleCrop = true
        imagePickerVC?.didFinishPickingPhotosHandle = {[weak self] (photos, _, _)in
            guard let this = self else {
                return
            }
            if let image = photos?.first {
                this.avatar.image = image
                this.vm.changeUserAvatar(image).subscribe(onNext: { (user) in
                    LSLUser.current().user = user
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                }).disposed(by: this.rx.disposeBag)
            }
        }
        navigationController?.present(imagePickerVC!, animated: true, completion: nil)
    }
}
