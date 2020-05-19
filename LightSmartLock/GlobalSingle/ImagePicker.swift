//
//  ImagePicker.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/19.
//  Copyright © 2020 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import TZImagePickerController

struct ImagePicker {
    
    static func present(maxImageCount: Int) -> Observable<[UIImage]> {
        
        return Observable<[UIImage]>.create { (observer) -> Disposable in
            
            guard let currentVC = RootViewController.topViewController() else {
                return Disposables.create()
            }
            
            guard let imagePickerVC = TZImagePickerController(maxImagesCount: maxImageCount, delegate: currentVC) else {
                return Disposables.create()
            }
            imagePickerVC.needCircleCrop = true
            
            imagePickerVC.didFinishPickingPhotosHandle = {(photos, _, _)in
                
                if let images = photos {
                    observer.onNext(images)
                    observer.onCompleted()
                }
            }
            
            currentVC.present(imagePickerVC, animated: true, completion: nil)
            
            return Disposables.create {
                imagePickerVC.dismiss(animated: true, completion: nil)
            }
            
        }
    }
}

extension UIViewController: TZImagePickerControllerDelegate {}

