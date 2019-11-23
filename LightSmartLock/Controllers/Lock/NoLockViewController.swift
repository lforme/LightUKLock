//
//  NoLockViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/22.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class NoLockViewController: UIViewController {

    @IBOutlet weak var mustRead: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var containerB: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorClassification.tableViewBackground.value
        containerA.backgroundColor = ColorClassification.viewBackground.value
        containerB.backgroundColor = ColorClassification.viewBackground.value
        
        containerA.setCircularShadow(radius: 3, color: ColorClassification.primary.value)
        containerB.setCircularShadow(radius: 3, color: ColorClassification.primary.value)
        
        mustRead.textColor = ColorClassification.textPrimary.value
        
        addButton.set(image: UIImage(named: "lock_add_icon"), title: "添加门锁", titlePosition: UIButton.Position.bottom, additionalSpacing: 20, state: UIControl.State())
        addButton.setTitleColor(ColorClassification.textPrimary.value, for: UIControl.State())
    }
    
    
}
