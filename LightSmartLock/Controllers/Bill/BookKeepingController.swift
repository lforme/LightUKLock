//
//  BookKeepingController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/4/27.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class BookKeepingFeeCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingAddCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class BookKeepingTimeCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}


class BookKeepingController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "记一笔"
        setupUI()
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ColorClassification.tableViewBackground.value
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingFeeCell", for: indexPath) as! BookKeepingFeeCell
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingAddCell", for: indexPath) as! BookKeepingAddCell
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookKeepingTimeCell", for: indexPath) as! BookKeepingTimeCell
            return cell
            
        default:
            fatalError()
        }
    }
}
