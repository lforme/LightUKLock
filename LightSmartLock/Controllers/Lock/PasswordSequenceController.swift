//
//  PasswordSequenceController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/19.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import PKHUD

class PasswordSequenceController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var digitalTimeLabel: UILabel!
    @IBOutlet weak var digitalEyeButton: UIButton!
    @IBOutlet weak var digitalLabel: UILabel!
    @IBOutlet weak var cardAddButton: UIButton!
    @IBOutlet weak var fingerAddButton: UIButton!
    @IBOutlet weak var bgView1: UIView!
    @IBOutlet weak var bgView2: UIView!
    @IBOutlet weak var bgView3: UIView!
    @IBOutlet weak var bgView4: UIView!
    @IBOutlet weak var fingerStackView: UIStackView!
    @IBOutlet weak var cardStackView: UIStackView!
    
    var pwd = "* * * * * *"
    var showPwd: String?
    lazy var disposeBag = DisposeBag()
    lazy var canAddFinger = true
    lazy var canAddCard = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "密码管理"
        setupUI()
        refresh()
        
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        clearsSelectionOnViewWillAppear = true
        
        digitalEyeButton.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        
        [bgView1, bgView2, bgView3, bgView4].forEach { (v) in
            v?.setCircularShadow(radius: 7, color: ColorClassification.primary.value)
        }
        fingerAddButton.set(image: UIImage(named: "home_pwd_add"), title: "添加指纹", titlePosition: .bottom, additionalSpacing: 16, state: .normal)
        cardAddButton.set(image: UIImage(named: "home_pwd_add"), title: "添加门卡", titlePosition: .bottom, additionalSpacing: 16, state: .normal)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 || indexPath.row == 0 {
            let pwdVC: PasswordManagementController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(pwdVC, animated: true)
        }
    }
    
//    @objc func fingerDetailTap(fingerModel: Any) {
//        
//        print(fingerModel)
//    }
//    
//    func cardDetailTap(cardModel: OpenLockInfoModel.Card) {
//        
//    }
    
    
    @IBAction func eyeButtonTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.digitalLabel.text = showPwd
        } else {
            self.digitalLabel.text = pwd
        }
    }
    
    @IBAction func addFingerTap(_ sender: UIButton) {
        if !canAddFinger {
            HUD.flash(.label("指纹添加已到上线"), delay: 2)
            return
        }
        let addFingerVC: AddFingerController = ViewLoader.Storyboard.controller(from: "InitialLock")
        navigationController?.pushViewController(addFingerVC, animated: true)
    }
    
    @IBAction func addCardTap(_ sender: UIButton) {
        if !canAddFinger {
            HUD.flash(.label("门卡添加已到上线"), delay: 2)
            return
        }
        let addCardVC: AddCardController = ViewLoader.Storyboard.controller(from: "InitialLock")
        navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    func refresh() {
        
        self.disposeBag = DisposeBag()
        
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁编号"), delay: 2)
            return
        }
        
        BusinessAPI.requestMapJSON(.getAllOpenWay(lockId: lockId), classType: OpenLockInfoModel.self)
            .subscribe(onNext: {[weak self] (model) in
                self?.showPwd = model.ladderNumberPasswordVO?.password
                self?.digitalTimeLabel.text = model.ladderNumberPasswordVO?.ladderNumberPasswordRecordVOList?.first?.triggerTime
                
                if let fingers = model.ladderFingerPrintVOList {
                    fingers.forEach { (f) in
                        let btn = UIButton(type: .custom)
                        btn.setTitleColor(ColorClassification.textPrimary.value, for: .normal)
                        btn.sizeToFit()
                        btn.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .disabled)
                        btn.setTitle(f.name, for: UIControl.State())
                        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        btn.set(image: UIImage(named: "home_pwd_finger_normal"), title: f.name ?? "-", titlePosition: .bottom, additionalSpacing: 16, state: .normal)
                        btn.set(image: UIImage(named: "home_pwd_finger_process"), title: f.name ?? "-", titlePosition: .bottom, additionalSpacing: 16, state: .disabled)
                        
    
                        self?.fingerStackView.insertArrangedSubview(btn, at: 0)
                        
                    }
                    self?.canAddFinger = fingers.count < 3
                }
                
                if let cards = model.ladderCardVOList {
                    cards.forEach { (f) in
                        let btn = UIButton(type: .custom)
                        btn.setTitleColor(ColorClassification.textPrimary.value, for: .normal)
                        btn.sizeToFit()
                        btn.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .disabled)
                        btn.setTitle(f.name, for: UIControl.State())
                        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        btn.set(image: UIImage(named: "home_pwd_card_normal"), title: f.name ?? "-", titlePosition: .bottom, additionalSpacing: 16, state: .normal)
                        btn.set(image: UIImage(named: "home_pwd_card_process"), title: f.name ?? "-", titlePosition: .bottom, additionalSpacing: 16, state: .disabled)
                        
                        self?.cardStackView.insertArrangedSubview(btn, at: 0)
                        
                        self?.canAddCard = cards.count < 3
                    }
                }
                
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            })
            .disposed(by: rx.disposeBag)
    }
}
