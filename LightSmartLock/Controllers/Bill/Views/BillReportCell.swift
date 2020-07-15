//
//  BillReportCell.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BillReportCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.isHidden = true
    }
    
    func bind(_ data: BillFlowReportSection.Data) {
        name.text = data.costCategoryName ?? "正在加载..."
        price.text = "￥ \(data.totalAmount)"
        count.text = "\(data.count)笔"
        if data.count != data.paidCount {
            progressView.isHidden = false
            progressView.progress = Float(data.paidCount) / Float(data.count)
            count.text = "\(data.paidCount)/\(data.count)笔"
        }
    }

}
