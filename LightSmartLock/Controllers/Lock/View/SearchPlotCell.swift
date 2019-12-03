//
//  SearchPlotCell.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class SearchPlotCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func bind(_ data: GoudaMapItemModel, keyword: String?) {
        guard let name = data.name, let pname = data.pname, let cityName = data.cityname, let address = data.address, let key = keyword else {
            return
        }
        
        let nameAttribute = NSMutableAttributedString(string: name)
        nameAttribute.setColorForText(key, with: ColorClassification.primary.value)
        nameLabel.attributedText = nameAttribute
        let addressAttribute = NSMutableAttributedString(string:"\(pname)-\(cityName)-\(address)")
        addressAttribute.setColorForText(key, with: ColorClassification.primary.value)
        addressLabel.attributedText = addressAttribute
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
