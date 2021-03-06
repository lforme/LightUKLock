//
//  DigitalPwdDetailController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxCocoa
import RxSwift

class DigitalPwdDetailController: UITableViewController, NavigationSettingStyle {
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    var vm: PasswordManagementViewModel!
    var dataSource: [OpenLockInfoModel.LadderNumberPasswordRecordVOList] = []
    var displayModel: OpenLockInfoModel.LadderNumberPasswordVO?
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "永久密码"
        setupUI()
        setupNavigationRightItem()
        bind()
        observerSceneChanged()
    }
    
    func observerSceneChanged() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            
            switch refreshType {
            case let .changeDigitalPwd(newPassword):
                let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DigitalPasswordCell
                cell?.passwordLabel.text = newPassword
                self?.displayModel?.password = newPassword
            default: break
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupNavigationRightItem() {
        createdRightNavigationItem(title: "修改密码", font: UIFont.systemFont(ofSize: 14, weight: .medium), image: nil, rightEdge: 8, color: .white).rx.tap.subscribe(onNext: {[unowned self] (_) in
            
            guard let oldPassword = self.displayModel?.password else {
                HUD.flash(.label("无法获取旧密码, 请稍后再试"), delay: 2)
                return
            }
            let changePasswordVC: ChangeDigitalPwdController = ViewLoader.Storyboard.controller(from: "Home")
            changePasswordVC.oldPassword = oldPassword
            self.navigationController?.pushViewController(changePasswordVC, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        vm.info.subscribe(onNext: {[weak self] (model) in
            self?.displayModel = model
            guard let list = model?.ladderNumberPasswordRecordVOList else {
                return
            }
            self?.dataSource = list
            self?.tableView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
        
        vm.extend.subscribe(onNext: {[weak self] (_) in
            self?.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 8
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 88
        case 1:
            return 44
        default:
            return 48
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalPasswordCell", for: indexPath) as! DigitalPasswordCell
            if let model = displayModel {
                cell.bind(model)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalPasswordStatusCell", for: indexPath) as! DigitalPasswordStatusCell
            cell.showLog {[weak self] (show) in
                self?.vm.extend.accept(show)
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalPasswordLogCell", for: indexPath) as! DigitalPasswordLogCell
            let data = dataSource[indexPath.row]
            cell.bind(data)
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            return self.vm.extend.value ? self.dataSource.count : 0
        default:
            return 0
        }
    }
}


class DigitalPasswordCell: UITableViewCell {
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var useDayLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(_ model: OpenLockInfoModel.LadderNumberPasswordVO) {
        guard var password = model.password, password.count == 6 else {
            return
        }
        let index = password.index(password.startIndex, offsetBy: 3)
        password.insert(contentsOf: "--", at: index)
        password = password.replacingOccurrences(of: "--", with: " ")
        passwordLabel.text = password
        
        guard let useDays = model.useDays else {
            return
        }
        useDayLabel.text = "密码已使用\(useDays)天"
    }
}

class DigitalPasswordStatusCell: UITableViewCell {
    
    @IBOutlet weak var extendButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    private var didSelected: ((Bool) -> Void)?
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        extendButton.set(image: UIImage(named: "up_arrow"), title: "展开", titlePosition: .left, additionalSpacing: 12, state: .normal)
        extendButton.set(image: UIImage(named: "down_arrow"), title: "收起", titlePosition: .left, additionalSpacing: 12, state: .selected)
    }
    
    @IBAction func extendTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.didSelected?(sender.isSelected)
    }
    
    func showLog(call: ((Bool)->Void)? ) {
        self.didSelected = call
    }
}

class DigitalPasswordLogCell: UITableViewCell {
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dotView.setCircular(radius: dotView.bounds.height / 2)
    }
    
    func bind(_ data: OpenLockInfoModel.LadderNumberPasswordRecordVOList) {
        statusLabel.text = data.statusName
        timeLabel.text = data.triggerTime?.toDate()?.toFormat("yyyy-MM-dd HH:mm:ss")
    }
}
