//
//  InviteBindingViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/13.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import EFQRCode

class InviteBindingViewController: UIViewController {
    
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    @IBAction func saveAction(_ sender: Any) {
    }
    
    @IBAction func sendAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
