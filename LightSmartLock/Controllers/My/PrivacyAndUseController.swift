//
//  PrivacyAndUseController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/5.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import WebKit

class PrivacyAndUseController: UITableViewController {

    enum SelectType: Int {
        case use = 0
        case privacy
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "使用条款和隐私政策"
        setupUI()
    }

    func setupUI() {
        tableView.tableFooterView = UIView()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch SelectType(rawValue: indexPath.row) {
        case .privacy:
            let url = ServerHost.shared.environment.host + "/share/policies_of_privacy.html"
            let privacyPolicyVC =  LSLWebViewController(navigationTitile: "使用条款", webUrl: url)
            navigationController?.pushViewController(privacyPolicyVC, animated: true)
        case .use:
            let url = ServerHost.shared.environment.host + "/share/terms_of_service.html"
            let privacyPolicyVC =  LSLWebViewController(navigationTitile: "使用条款", webUrl: url)
            navigationController?.pushViewController(privacyPolicyVC, animated: true)
        default:
            break
        }
    }
}
