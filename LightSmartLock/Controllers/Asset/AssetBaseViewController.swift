//
//  AssetBaseViewController.swift
//  LightSmartLock
//
//  Created by changjun on 2020/5/18.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class AssetBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.tintColor = UIColor(contrastingBlackOrWhiteColorOn: ColorClassification.primary.value, isFlat: true)
    }

}
