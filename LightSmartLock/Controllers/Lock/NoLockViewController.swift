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
    @IBOutlet weak var dotView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        dotView.setCircular(radius: 4)
        containerA.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        mustRead.textColor = ColorClassification.textPrimary.value
        
        addButton.setCircular(radius: 7)
        addButton.addTarget(self, action: #selector(self.gotoSelectedLockVC), for: .touchUpInside)
    }
    
    @objc func gotoSelectedLockVC() {
        
        let selectVC: SelectLockTypeController = ViewLoader.Storyboard.controller(from: "InitialLock")
        selectVC.kind = .edited
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
}
