//
//  TempPasswordLogView.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate

class TempPasswordLogView: UIView {
    
    enum ViewKind {
        case multiple
        case single
    }
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var closedButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var dataSource: [TempPasswordRecordLog.ListModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var kind: ViewKind = .multiple {
        didSet {
            updateUI()
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        undoButton.setCircular(radius: 3)
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "PasswordChangeStatusCell", bundle: nil), forCellReuseIdentifier: "PasswordChangeStatusCell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        self.bottomContainer.setCircularShadow(radius: 7, color: ColorClassification.textPlaceholder.value)
        
        
    }
    
    private func updateUI() {
        switch self.kind {
        case .multiple:
            bottomContainer.isHidden = false
            
        case .single:
            bottomContainer.removeFromSuperview()
            bottomContainer.isHidden = true
        }
        layoutIfNeeded()
    }
    
    func updateListModel(_ model: TempPasswordRecordLog) {
        if let endDate = model.surplusDate?.toDate(), let hours = (endDate.date - Date()).hour {
            timeLeftLabel.text = "剩余时间 \(hours)小时"
        }
        undoButton.setTitle(model.status.description, for: .normal)
        undoButton.setBackgroundImage(UIImage(color: #colorLiteral(red: 0.7333333333, green: 0.1921568627, blue: 0.2823529412, alpha: 1), size: undoButton.bounds.size), for: .normal)
        if model.status == TempPasswordRecordLog.Status.normal {
            undoButton.isUserInteractionEnabled = true
        } else {
            undoButton.isUserInteractionEnabled = false
        }
    }
}


extension TempPasswordLogView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordChangeStatusCell", for: indexPath) as! PasswordChangeStatusCell
        
        (indexPath.row == 0) ? (cell.topLine.isHidden = true) : (cell.topLine.isHidden = false)
        let data = dataSource[indexPath.row]
        cell.timeLabel.text = data.triggerTime?.toDate()?.toFormat("yyyy-MM-dd HH:mm:ss")
        cell.remarkLabel.text = data.getter
        
        return cell
    }
}
