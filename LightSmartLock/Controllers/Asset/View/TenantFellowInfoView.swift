//
//  TenantFellowInfoView.swift
//  LightSmartLock
//
//  Created by changjun on 2020/4/26.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Reusable

class TenantFellowInfoView: UIView, NibLoadable {

    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var statusBtn: UIButton!
    
    private var didDeleted: (() -> Void)?
    private var didEdited: (() -> Void)?
    
    func config(with fellow: TenantMember, didDeleted: (() -> Void)?, didEdited: (() -> Void)?) {
        infoLabel.text = (fellow.userName ?? "") + " " + (fellow.phone ?? "")
        self.didDeleted = didDeleted
        self.didEdited = didEdited
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        didDeleted?()
    }
    
    @IBAction func editAction(_ sender: Any) {
        didEdited?()
    }
}
