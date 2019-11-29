//
//  MessageCenterController.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

fileprivate class MessageCenterCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
        
        [ignoreButton, agreeButton].forEach { (btn) in
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = ColorClassification.textPlaceholder.value.cgColor
            btn?.layer.cornerRadius = 3
        }
        // 这期不做
        buttonContainer.removeArrangedSubview(ignoreButton)
        buttonContainer.removeArrangedSubview(agreeButton)
    }
}

class MessageCenterController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "消息中心"
        setupUI()
        setupRightNavigationItem()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.emptyDataSetSource = self
    }
    
    func setupRightNavigationItem() {
        createdRightNavigationItem(title: nil, image: UIImage(named: "message_filter"))
    }
}
