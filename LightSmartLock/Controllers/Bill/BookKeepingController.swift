//
//  BookKeepingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class BookKeepingFeeCell: UITableViewCell {
    
    @IBOutlet weak var feesButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingAddCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingTimeCell: UITableViewCell {
    
    @IBOutlet weak var timePickButton: UIButton!
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}


class BookKeepingController: UITableViewController {
    
    var assetId: String?
    var contractId: String?
    var vm: BookKeepingViewModel?
    
    deinit {
        print(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "记一笔"
        setupUI()
        bind()
        setupNavigationRightItem()
    }
    
    func bind() {
        guard let assetId = self.assetId, let contractId = self.contractId else {
            HUD.flash(.label("无法获取资产信息"), delay: 2)
            return
        }
        self.vm = BookKeepingViewModel(assetId: assetId, contractId: contractId)
        tableView.reloadData()
    }
    
    func setupNavigationRightItem() {
        let saveButton = createdRightNavigationItem(title: "保存", font: nil, image: nil, rightEdge: 8, color: ColorClassification.navigationItem.value)
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
    }
    
    @objc func saveButtonTap() {
        guard let vm = self.vm else {
            return
        }
        if vm.verificationParameters() {
            vm.parametersBuilder().subscribe(onNext: {[weak self] (success) in
                if success {
                    HUD.flash(.label("成功"), delay: 2)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    HUD.flash(.label("失败"), delay: 2)
                }
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return vm?.itemList.count ?? 0
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 140
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 8
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row != 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            vm?.deleteItemBy(index: indexPath.row, complete: {[weak self] in
                self?.tableView.reloadSections([0], animationStyle: .automatic)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            vm?.addItem {[weak self] in
                self?.tableView.reloadSections([0], animationStyle: .automatic)
            }
        case 2:
            guard let vm = self.vm else {
                return
            }
            let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 2)) as! BookKeepingTimeCell
            DatePickerController.rx.present(with: "yyyy-MM-dd hh:mm:ss", mode: .date, maxDate: nil, miniDate: nil).bind(to: vm.obTime).disposed(by: cell.disposeBag)
            vm.obTime.subscribe(onNext: { (date) in
                if let value = date {
                    cell.timePickButton.setTitle(value, for: UIControl.State())
                } else {
                    cell.timePickButton.setTitle("请选择", for: UIControl.State())
                }
            }).disposed(by: cell.disposeBag)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingFeeCell", for: indexPath) as! BookKeepingFeeCell
            if let bindModel = vm?.itemList[indexPath.row] {
                
                cell.priceTextField.rx.text.orEmpty.changed
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .distinctUntilChanged().bind(to: bindModel.obAmount)
                    .disposed(by: cell.disposeBag)
                if let price = bindModel.convertToAddFlowParameter().amount {
                    cell.priceTextField.text = price
                } else {
                    cell.priceTextField.text = nil
                }
                
                cell.feesButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                    guard let this = self else { return }
                    let selectedVC: SelectorFeesController = ViewLoader.Storyboard.controller(from: "Bill")
                    this.navigationController?.pushViewController(selectedVC, animated: true)
                    
                    selectedVC.didSelected = {[weak self] (name, id) in
                        bindModel.obCostCategoryId.accept(id)
                        bindModel.obCostName.accept(name)
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }).disposed(by: cell.disposeBag)
                
                if let feesName = bindModel.convertToAddFlowParameter().costName {
                    cell.feesButton.setTitle(feesName, for: UIControl.State())
                } else {
                    cell.feesButton.setTitle("请选择", for: UIControl.State())
                }
                
                cell.typeButton.rx.tap.flatMapLatest { (_) -> Observable<Int> in
                    return DataPickerController.rx.present(with: "选择流水类型", items: [["收入水流", "支出流水"]]).map {
                        if let v = $0.last?.value, v == "收入水流" {
                            return 1
                        } else {
                            return -1
                        }
                    }
                }.subscribe(onNext: {[weak self] (value) in
                    bindModel.obType.accept(value)
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }).disposed(by: cell.disposeBag)
                
                if let type = bindModel.convertToAddFlowParameter().turnoverType {
                    if type == 1 {
                        cell.typeButton.setTitle("收入流水", for: UIControl.State())
                    } else {
                        cell.typeButton.setTitle("支出流水", for: UIControl.State())
                    }
                } else {
                    cell.typeButton.setTitle("请选择", for: UIControl.State())
                }
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingAddCell", for: indexPath) as! BookKeepingAddCell
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingTimeCell", for: indexPath) as! BookKeepingTimeCell
            return cell
            
        default:
            fatalError()
        }
    }
}
