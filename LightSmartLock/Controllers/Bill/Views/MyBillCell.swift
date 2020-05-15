//
//  MyBillCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import SnapKit

class MyBillCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var latestDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rushRentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(_ data: MyBillModel) {
        assetName.text = data.assetName
        let days = data.deadlineDays ?? 0
        latestDate.text = "距最晚付款日\(days)天"
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
            if status == 0 {
                confirmButton.isHidden = true
                rushRentButton.isHidden = false
            } else if status == 999 {
                rushRentButton.isHidden = true
                confirmButton.isHidden = false
            }
        }
        self.layoutIfNeeded()
    }
}
