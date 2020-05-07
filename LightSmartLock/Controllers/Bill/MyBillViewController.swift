//
//  MyBillViewController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit

class MyBillViewController: UIViewController {

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var leasedButton: UIButton!
    @IBOutlet weak var paidButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "我的账单"
        setupUI()
    }

    func setupUI() {
        [allButton, pendingButton, leasedButton, pendingButton].forEach { (btn) in
            btn?.setTitleColor(ColorClassification.primary.value, for: .selected)
        }
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 250
        tableView.register(UINib(nibName: "MyBillCell", bundle: nil), forCellReuseIdentifier: "MyBillCell")
        tableView.dataSource = self
        tableView.separatorStyle = .none
       
    }
}

extension MyBillViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyBillCell", for: indexPath) as! MyBillCell
        return cell
    }
}
