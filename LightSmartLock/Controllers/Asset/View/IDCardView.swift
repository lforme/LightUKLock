//
//  IDCardView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/28.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Kingfisher
import Reusable

class IDCardView: UIView, NibOwnerLoadable {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet var tapGR: UITapGestureRecognizer!
    
    var urlStr: String? {
        didSet {
            updateUI()
        }
    }
    
    
    var placeImage: UIImage? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadNibContent()
        
        updateUI()
        tapGR.rx.event
            .subscribe(onNext: { (tap) in
                print("tap")
            })
            .disposed(by: rx.disposeBag)
    }
    
    func updateUI() {
        
        if let urlStr = urlStr,
            let url = URL.init(string: urlStr) {
            imageView.kf.setImage(with: url)
            deleteBtn.isHidden = false
        } else {
            imageView.image = placeImage
            deleteBtn.isHidden = true
        }
    }
    
}
