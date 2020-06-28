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
import AlignedCollectionViewFlowLayout

class PasswordSequenceController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    @IBOutlet weak var digitalTimeLabel: UILabel!
    @IBOutlet weak var digitalEyeButton: UIButton!
    @IBOutlet weak var digitalLabel: UILabel!
    @IBOutlet weak var bgView1: UIView!
    @IBOutlet weak var bgView2: UIView!
    @IBOutlet weak var bgView3: UIView!
    @IBOutlet weak var bgView4: UIView!
    @IBOutlet weak var fingerCollectionView: UICollectionView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    var fingerCellDs: RxCollectionViewSectionedReloadDataSource<SectionModel<String, OpenLockInfoModel.Finger>>!
    var cardCellDs: RxCollectionViewSectionedReloadDataSource<SectionModel<String, OpenLockInfoModel.Card>>!
    
    var pwd = "* * * * * *"
    var showPwd: String?
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "密码管理"
        setupUI()
        refresh()
        bind()
        observerNotification()
    }
    
    func observerNotification() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .editCard, .editFinger:
                self?.refresh()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        fingerCollectionView.rx.modelSelected(OpenLockInfoModel.Finger.self)
            .subscribe(onNext: {[weak self] (finger) in
                
                if finger.isAddButton {
                    let addFingerVC: AddFingerController = ViewLoader.Storyboard.controller(from: "InitialLock")
                    self?.navigationController?.pushViewController(addFingerVC, animated: true)
                } else {
                    let fingerDetailVC: FingerDetailController = ViewLoader.Storyboard.controller(from: "Home")
                    fingerDetailVC.fingerModel = finger
                    self?.navigationController?.pushViewController(fingerDetailVC, animated: true)
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        cardCollectionView.rx.modelSelected(OpenLockInfoModel.Card.self)
            .subscribe(onNext: {[weak self] (card) in
                
                if card.isAddButton {
                    let addCardVC: AddCardController = ViewLoader.Storyboard.controller(from: "InitialLock")
                    self?.navigationController?.pushViewController(addCardVC, animated: true)
                } else {
                    let cardDetailVC: CardDetailController = ViewLoader.Storyboard.controller(from: "Home")
                    cardDetailVC.keyNumber = card.keyNum
                    cardDetailVC.keyId = card.id
                    cardDetailVC.cardName = card.name
                    self?.navigationController?.pushViewController(cardDetailVC, animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        clearsSelectionOnViewWillAppear = true
        
        digitalEyeButton.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        
        [bgView1, bgView2, bgView3, bgView4].forEach { (v) in
            v?.setCircularShadow(radius: 7, color: ColorClassification.primary.value)
        }
        
        [fingerCollectionView, cardCollectionView].forEach { (cv) in
            cv?.register(UINib(nibName: "PasswordSequenceCell", bundle: nil), forCellWithReuseIdentifier: "PasswordSequenceCell")
            let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
            alignedFlowLayout.scrollDirection = .horizontal
            alignedFlowLayout.minimumLineSpacing = 8
            alignedFlowLayout.minimumInteritemSpacing = 8
            alignedFlowLayout.itemSize = CGSize(width: 80 * kLSRem, height: 80)
            cv?.contentInset = UIEdgeInsets(top: 4, left: 2, bottom: 4, right: 2)
            cv?.collectionViewLayout = alignedFlowLayout
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vm = PasswordManagementViewModel()
            let digitalPwdVC: DigitalPwdDetailController = ViewLoader.Storyboard.controller(from: "Home")
            digitalPwdVC.vm = vm
            vm.refresh()
            navigationController?.pushViewController(digitalPwdVC, animated: true)
        }
        
        if indexPath.row == 2 {
            let pwdVC: PasswordManagementController = ViewLoader.Storyboard.controller(from: "Home")
            navigationController?.pushViewController(pwdVC, animated: true)
        }
    }
    
    @IBAction func eyeButtonTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.digitalLabel.text = showPwd
        } else {
            self.digitalLabel.text = pwd
        }
    }
    
    func refresh() {
        
        self.disposeBag = DisposeBag()
        
        guard let lockId = LSLUser.current().lockInfo?.ladderLockId else {
            HUD.flash(.label("无法获取门锁编号"), delay: 2)
            return
        }
        
        BusinessAPI.requestMapJSON(.getAllOpenWay(lockId: lockId), classType: OpenLockInfoModel.self)
            .subscribe(onNext: {[weak self] (model) in
                guard let this = self else { return }
                self?.showPwd = model.ladderNumberPasswordVO?.password
                self?.digitalTimeLabel.text = model.ladderNumberPasswordVO?.ladderNumberPasswordRecordVOList?.first?.triggerTime
                
                if var fingers = model.ladderFingerPrintVOList {
                    
                    if fingers.count < 3 {
                        var addF = OpenLockInfoModel.Finger()
                        addF.isAddButton = true
                        addF.name = "添加指纹"
                        fingers.append(addF)
                    }
                    
                    let array = [SectionModel(model: "指纹model", items: fingers)]
                    let dataSource = Observable.just(array)
                    
                    this.fingerCellDs = RxCollectionViewSectionedReloadDataSource<SectionModel<String, OpenLockInfoModel.Finger>>(configureCell: { (ds, cv, ip, item) -> PasswordSequenceCell in
                        let cell = cv.dequeueReusableCell(withReuseIdentifier: "PasswordSequenceCell", for: ip) as! PasswordSequenceCell
                        cell.name.text = item.name
                        
                        if item.isAddButton {
                            cell.icon.image = UIImage(named: "home_pwd_add")
                        } else {
                            cell.icon.image = UIImage(named: "home_pwd_finger_normal")
                        }
                        
                        return cell
                    })
                    
                    dataSource.bind(to: this.fingerCollectionView.rx.items(dataSource: this.fingerCellDs))
                        .disposed(by: this.disposeBag)
                    
                }
                
                if var cards = model.ladderCardVOList {
                    if cards.count < 3 {
                        var addC = OpenLockInfoModel.Card()
                        addC.isAddButton = true
                        addC.name = "添加门卡"
                        cards.append(addC)
                    }
                    
                    let array = [SectionModel(model: "门卡Model", items: cards)]
                    let dataSource = Observable.just(array)
                    
                    this.cardCellDs = RxCollectionViewSectionedReloadDataSource<SectionModel<String, OpenLockInfoModel.Card>>(configureCell: { (ds, cv, ip, item) -> PasswordSequenceCell in
                        let cell = cv.dequeueReusableCell(withReuseIdentifier: "PasswordSequenceCell", for: ip) as! PasswordSequenceCell
                        cell.name.text = item.name
                        
                        if item.isAddButton {
                            cell.icon.image = UIImage(named: "home_pwd_add")
                        } else {
                            cell.icon.image = UIImage(named: "home_pwd_card_normal")
                        }
                        
                        return cell
                    })
                    
                    dataSource.bind(to: this.cardCollectionView.rx.items(dataSource: this.cardCellDs))
                        .disposed(by: this.disposeBag)
                }
                
                }, onError: { (error) in
                    PKHUD.sharedHUD.rx.showError(error)
            })
            .disposed(by: rx.disposeBag)
    }
}
