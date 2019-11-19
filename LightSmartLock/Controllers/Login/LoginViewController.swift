//
//  LoginViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit


class LoginViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var phoneContainerView: UIView!
    @IBOutlet weak var pwdContainerView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        interactiveNavigationBarHidden = true
        
        tableView.backgroundColor = ColorClassification.viewBackground.value
        titleLabel.textColor = ColorClassification.textPrimary.value
        companyLabel.textColor = ColorClassification.textDescription.value
        
        phoneContainerView.setCircular(radius: 3)
        pwdContainerView.setCircular(radius: 3)
        loginButton.setCircular(radius: 3)
        
        eyeButton.setImage(UIImage(named: "logig_eys_open"), for: .selected)
        eyeButton.setImage(UIImage(named: "login_eys_close"), for: .normal)
        
        pwdTextField.placeholderColor = ColorClassification.textPlaceholder.value
        phoneTextField.placeholderColor = ColorClassification.textPlaceholder.value
        phoneTextField.textColor = ColorClassification.textOpaque78.value
        pwdTextField.textColor = ColorClassification.textOpaque78.value
    }

}
