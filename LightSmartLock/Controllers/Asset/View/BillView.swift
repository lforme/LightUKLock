//
//  BillView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/20.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Reusable

class BillView: UIView, NibLoadable {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var latestDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    static func loadFromNib(with model: MyBillModel) -> BillView {
        
        let view = BillView.loadFromNib()
        view.bind(model)
        return view
    }

    private func bind(_ data: MyBillModel) {
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
       }

}
