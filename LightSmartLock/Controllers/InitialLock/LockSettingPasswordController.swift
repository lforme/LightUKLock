//
//  LockSettingPasswordController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import CBPinEntryView

class LockSettingPasswordController: UIViewController {
    
    @IBOutlet weak var passwordInput: CBPinEntryView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定门锁"
        setupUI()
    }
    
    func setupUI() {
        nextButton.setCircular(radius: nextButton.bounds.height / 2)
        
        passwordInput.entryCornerRadius = 3
        passwordInput.entryBorderWidth = 1
        passwordInput.entryDefaultBorderColour = #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.12)
        passwordInput.entryBorderColour = ColorClassification.primary.value
        passwordInput.entryEditingBackgroundColour = UIColor.white
        passwordInput.entryBackgroundColour = UIColor.white
        passwordInput.entryTextColour = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 1)
        passwordInput.delegate = self
    }
}

extension LockSettingPasswordController: CBPinEntryViewDelegate {
    
    func entryChanged(_ completed: Bool) {
        
    }
    
    func entryCompleted(with entry: String?) {
       
    }
}
