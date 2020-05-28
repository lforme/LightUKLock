//
//  MyBillCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import MessageUI

class MyBillCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var latestDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rushRentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    weak var controller: MyBillViewController?
    private(set) var disposeBag = DisposeBag()
    var data: MyBillModel?
    
    override func prepareForReuse() {
        stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
        }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview()
        }
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.setCircular(radius: 7)
        
        sendButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self?.controller else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: nil)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let deadLineDate = this.data?.deadlineDays ?? 0
            let total = this.data?.amount ?? 0
            let value = this.data?.billItemDTOList?.compactMap { $0 }.map {
                "\($0.costCategoryName ?? ""), ￥\($0.amount ?? 0), 周期:\($0.cycleStartDate ?? "") 至 \($0.cycleEndDate) \n"
            }
            guard let v = value else { return }
            
            let sendStr = """
            [账单信息]
            费用明细
            - - - - - - -
            \(v.joined())
            - - - - - - -
            距最晚付款日:\(deadLineDate)天
            合计金额：￥\(total)
            """
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    messageVC.messageComposeDelegate = this.controller
                    this.controller?.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
            print(sendStr)
        }).disposed(by: disposeBag)
        
        rushRentButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self?.controller else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: 0)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let money = this.data?.amount ?? 0.0
            let sendStr = "尊敬的租客，您近期有一笔账单已逾期，金额：\(money)元，请您尽快缴纳，谢谢"
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    messageVC.messageComposeDelegate = this.controller
                    this.controller?.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
        }).disposed(by: disposeBag)
    }
    
    func bind(_ data: MyBillModel) {
        self.data = data
        assetName.text = data.assetName
        let days = data.deadlineDays ?? 0
        if days < 0 {
            latestDate.text = "已逾期\(days)天"
            latestDate.textColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
        } else {
            latestDate.text = "距最晚付款日\(days)天"
            latestDate.textColor = ColorClassification.textDescription.value
        }
        let money = data.amount ?? 0.00
        amount.text = "￥\(money)"
        
        if let itemList = data.billItemDTOList {
            itemList.forEach { (item) in
                let v: FeeItemView = ViewLoader.Xib.view()
                stackView.addArrangedSubview(v)
                v.snp.makeConstraints { (maker) in
                    maker.left.right.equalTo(v.superview!)
                }
                let itemMoney = item.amount ?? 0.00
                v.amount.text = "￥\(itemMoney)"
                v.cotegoryName.text = item.costCategoryName
                let startDate = item.cycleStartDate ?? "开始"
                let endDate = item.cycleEndDate ?? "结束"
                v.date.text = "\(startDate) 至 \(endDate)"
            }
        }
        
        if let status = data.billStatus {
            if status == -1 {
                rushRentButton.isHidden = false
                confirmButton.isHidden = false
                sendButton.isHidden = false
            } else if status == 0 || status == 1 {
                confirmButton.isHidden = false
                rushRentButton.isHidden = true
                sendButton.isHidden = false
            } else if status == 999 {
                sendButton.isHidden = false
                rushRentButton.isHidden = true
                confirmButton.isHidden = true
            } else {
                rushRentButton.isHidden = true
                confirmButton.isHidden = false
            }
        }
        
        if LSLUser.current().scene?.roleType == .some(.member) || LSLUser.current().scene?.roleType == .some(.admin) {
            self.confirmButton.isHidden = false
            self.sendButton.isHidden = true
            self.rushRentButton.isHidden = true
        }
        
        self.layoutIfNeeded()
    }
}


extension MyBillViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
