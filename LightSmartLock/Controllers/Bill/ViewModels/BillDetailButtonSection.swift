//
//  BillDetailButtonSection.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift
import MessageUI

final class BillDetailButtonSection: ListSectionController {
    
    private var data: Data!
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 16, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BillDetailButtonCell", bundle: nil, for: self, at: index) as? BillDetailButtonCell else {
            fatalError()
        }
        
        if data.billStatus == -1 {
            cell.rushRentButton.isHidden = false
            cell.confirmButton.isHidden = true
            cell.sendButton.isHidden = false
        } else if data.billStatus == 0 || data.billStatus == 1 {
            cell.confirmButton.isHidden = false
            cell.rushRentButton.isHidden = true
            cell.sendButton.isHidden = false
        } else if data.billStatus == 999 {
            cell.sendButton.isHidden = false
            cell.rushRentButton.isHidden = true
            cell.confirmButton.isHidden = true
        } else {
            cell.rushRentButton.isHidden = true
            cell.confirmButton.isHidden = true
        }
        
        cell.confirmButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            let confirmVC: ConfirmArrivalController = ViewLoader.Storyboard.controller(from: "Bill")
            confirmVC.totalMoney = this.data.totalMoney
            confirmVC.billId = this.data.billId
            this.viewController?.navigationController?.pushViewController(confirmVC, animated: true)
        }).disposed(by: cell.disposeBag)
        
        
        cell.sendButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self?.viewController else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: nil)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let deadLineDays = this.data.model?.deadlineDays ?? 0
            let total = this.data?.model?.amountPayable ?? 0
            let value = this.data?.model?.billItemDTOList?.compactMap { $0 }.map {
                "\($0.costCategoryName ?? ""), ￥\($0.amount ?? 0), 周期:\($0.cycleStartDate ?? "") 至 \($0.cycleEndDate) \n"
            }
            guard let v = value else { return }
            
            let sendStr = """
            [账单信息]
            费用明细
            - - - - - - -
            \(v.joined())
            - - - - - - -
            距最晚付款日:\(deadLineDays)天
            合计金额：￥\(total)
            """
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    let vc = this.viewController as! BillDetailController
                    messageVC.messageComposeDelegate = vc
                    this.viewController?.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
            print(sendStr)
        }).disposed(by: cell.disposeBag)
        
        cell.rushRentButton.rx.tap.flatMapLatest {[weak self] (_) -> Observable<Int> in
            guard let vc = self?.viewController else {
                return .error(AppError.reason("发生未知错误"))
            }
            return vc.showActionSheet(title: "选择发送方式", message: nil, buttonTitles: ["短信", "取消"], highlightedButtonIndex: 0)
        }.subscribe(onNext: {[weak self] (buttonIndex) in
            guard let this = self else { return }
            let money = this.data?.model?.amountPayable ?? 0.0
            let sendStr = "尊敬的租客，您近期有一笔账单已逾期，金额：\(money)元，请您尽快缴纳，谢谢"
            switch buttonIndex {
            case 0:
                if MFMessageComposeViewController.canSendText() {
                    let messageVC = MFMessageComposeViewController()
                    messageVC.body = sendStr
                    let vc = this.viewController as! BillDetailController
                    messageVC.messageComposeDelegate = vc
                    this.viewController?.present(messageVC, animated: true, completion: nil)
                }
                
            default :break
            }
        }).disposed(by: cell.disposeBag)
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? Data
    }
}

extension BillDetailButtonSection {
    
    final class Data: NSObject, ListDiffable {
        
        let billStatus: Int
        let billId: String
        let totalMoney: Double
        var model: BillInfoDetail?
        
        init(status: Int, billId: String, totalMoney: Double) {
            self.billStatus = status
            self.billId = billId
            self.totalMoney = totalMoney
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return self
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            return isEqual(self)
        }
    }
}


extension BillDetailController: MFMessageComposeViewControllerDelegate {
    
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
