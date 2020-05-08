//
//  TenantContractCell.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/7.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class TenantContractCell: UITableViewCell {

    var model: TenantContractAndBillsDTO? {
        didSet {
            let houseName = model?.tenantContractDTO?.houseName ?? ""
            let tenantName = model?.tenantContractDTO?.tenantName ?? ""
            nameLabel.text = "\(houseName) \(tenantName)"
            
            let rental = model?.tenantContractDTO?.rental?.description ?? ""
            
            let payMethod = model?.tenantContractDTO?.payMethod?.description ?? ""
            let detail = "\(rental)元·\(payMethod)"
            detailBtn.setTitle(detail, for: .normal)
            
            startDateLabel.text = model?.tenantContractDTO?.startDate
            endDateLabel.text = model?.tenantContractDTO?.endDate
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailBtn: UIButton!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
