//
//  InviteBindingViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/13.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import EFQRCode
import PKHUD

class InviteBindingViewController: AssetBaseViewController {
    
    
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
        if let saveImage = QRCodeImageView.image {
            UIImageWriteToSavedPhotosAlbum(saveImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let saveImage = QRCodeImageView.image {
            //            let vc = UIActivityViewController(activityItems: [saveImage], applicationActivities: nil)
            //            self.present(vc, animated: true, completion: nil)
            ShareTool.share(platform: .weixin, contentText: nil, url: nil, title: nil, images: [saveImage]) { (success) in
                print("分享: \(success)")
                
            }
        }
        
        
    }
}

extension InviteBindingViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            HUD.flash(.label("保存成功"), delay: 2)
        } else {
            PKHUD.sharedHUD.rx.showError(error)
        }
    }
    
}
