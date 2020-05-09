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
import RxCocoa
import RxSwift
import TZImagePickerController
import HandyJSON
import PKHUD

struct IdCardDTO: HandyJSON {
    var address: String?
    var authority: String?
    var birth: String?
    var id: String?
    var name: String?
    var nation: String?
    var sex: String?
    var validDate: [String]?
    var valid_date: String?
}


class IDCardView: UIView, NibOwnerLoadable, TZImagePickerControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet var tapGR: UITapGestureRecognizer!
    
    var updateIDCard: ((String) -> Void)?
    
    var urlStr: String? {
        didSet {
            updateUI()
        }
    }
    
    var isFront: Bool?
    
    
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
            .flatMap { [unowned self]_ in
                return self.selectImage()
                    .flatMap { image -> Observable<String?> in
                        guard let image = image else {
                            return .empty()
                        }
                        return self.uploadImage(image)
                }
                .flatMap { url -> Observable<(String?, IdCardDTO?)> in
                    guard var url = url else {
                        return .empty()
                    }
                    url = ServerHost.shared.environment.host + url
                    return self.recognize(imageUrl: url).map { (url, $0) }
                }
        }
        .subscribe(onNext: { [weak self](url, model) in
            if let isFront = self?.isFront {
                if isFront && model?.id != nil {
                    if let url = url {
                        self?.urlStr = url
                    }
                    
                    if let idCard = model?.id {
                        self?.updateIDCard?(idCard)
                    }
                } else if !isFront && model?.valid_date != nil {
                    if let url = url {
                        self?.urlStr = url
                    }
                } else {
                    HUD.flash(.label("证件识别失败"), delay: 1)
                    
                }
            } else {
                if model?.id != nil || model?.valid_date != nil {
                    if let url = url {
                        self?.urlStr = url
                    }
                    
                    if let idCard = model?.id {
                        self?.updateIDCard?(idCard)
                    }
                } else {
                    HUD.flash(.label("证件识别失败"), delay: 1)
                }
            }
            
            
            }, onError:  { _ in
                HUD.flash(.label("证件识别失败"), delay: 1)
                
        })
            .disposed(by: rx.disposeBag)
    }
    
    func selectImage() -> Observable<UIImage?> {
        return Observable<UIImage?>.create { (observer) -> Disposable in
            let imagePickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
            imagePickerVC?.needCircleCrop = true
            imagePickerVC?.didFinishPickingPhotosHandle = { (photos, _, _)in
                let image = photos?.first
                observer.onNext(image)
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerVC!, animated: true, completion: nil)
            
            return Disposables.create()
        }
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
    
    @IBAction func deleteAction(_ sender: Any) {
        urlStr = nil
    }
    
    func uploadImage(_ image: UIImage) -> Observable<String?> {
        return BusinessAPI.requestMapAny(.uploadImage(image, description: "身份证识别")).map { (res) -> String? in
            let json = res as? [String: Any]
            let headPicUrl = json?["data"] as? String
            return headPicUrl
        }
    }
    
    func recognize(imageUrl: String) -> Observable<IdCardDTO> {
        return BusinessAPI2.requestMapJSON(.recognizeIDCard(url: imageUrl), classType: IdCardDTO.self)
    }
    
}
