//
//  MyListCell.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift

class MyListCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var notiView: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if selected {
//            indicator.backgroundColor = ColorClassification.primary.value
//        } else {
//            indicator.backgroundColor = ColorClassification.viewBackground.value
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.textColor = ColorClassification.textPrimary.value
        address.textColor = ColorClassification.textDescription.value
        message.textColor = ColorClassification.textDescription.value
        bgView.backgroundColor = ColorClassification.viewBackground.value
        self.contentView.backgroundColor = ColorClassification.tableViewBackground.value
        
        bgView.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        indicator.setCircular(radius: 3)
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                bgView.layer.shadowColor = UIColor.clear.cgColor
                bgView.layer.cornerRadius = 7
                bgView.layer.borderWidth = 0.5
                bgView.layer.borderColor = #colorLiteral(red: 0.2705882353, green: 0.2745098039, blue: 0.2784313725, alpha: 1).cgColor
            }
        } else {}
    }
    
    func bind(_ data: SceneListModel) {
        name.text = data.buildingName ?? "-"
        address.text = data.buildingAdress ?? "-"
        if let lockInfo = data.lockType {
            message.text = "已安装门锁, 门锁类型: \(lockInfo)"
        }
        
        
        guard let currentId = LSLUser.current().scene?.ladderAssetHouseId, let id = data.ladderAssetHouseId else {
            return
        }
        
        if currentId == id {
            indicator.backgroundColor = ColorClassification.primary.value
        } else {
            indicator.backgroundColor = ColorClassification.viewBackground.value
        }
    }
}
