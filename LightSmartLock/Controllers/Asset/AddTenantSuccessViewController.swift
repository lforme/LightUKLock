//
//  AddTenantSuccessViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/12.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import EFQRCode

class TenantSuccessInfo {
    var houseNum: String?
    var name: String?
    var cycleDate: String?
    var rental: String?
}

class AddTenantSuccessViewController: AssetBaseViewController {
    
    var successInfo: TenantSuccessInfo!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var houseNumLabel: UILabel!
    
    @IBOutlet weak var cycleDateLabel: UILabel!
    
    @IBOutlet weak var rentalLabel: UILabel!
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        
        houseNumLabel.text = successInfo.houseNum
        nameLabel.text = successInfo.name
        cycleDateLabel.text = successInfo.cycleDate
        rentalLabel.text = successInfo.rental
        
        BusinessAPI2.requestMapAny(.getDownloadAddress)
            .subscribe(onNext: { [weak self](response) in
                if let response = response as? [String: Any],
                    let urlStr = response["data"] as? String,
                    let image = EFQRCode.generate(content: urlStr) {
                    self?.QRCodeImageView.image = UIImage.init(cgImage: image)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func getRentalAction(_ sender: Any) {
        NotificationCenter.default.post(name: .gotoAssetDetail, object: nil)
    }
    
}
