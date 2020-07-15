//
//  AboutUsController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/8.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class AboutUsController: UIViewController, NavigationSettingStyle {
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var privacyAndService: UIControl!
    @IBOutlet weak var cleanCache: UIControl!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    deinit {
        print("deinit \(self)")
    }
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    lazy var diskStorage = NetworkDiskStorage(autoCleanTrash: false, path: "lightSmartLock.network")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "关于我们"
        bind()
    }
    
    func bind() {
        appNameLabel.text = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
        
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        versionLabel.text = version + "  build(\(build))"
        
        let filePath = diskStorage.db.path
        var fileSize : UInt64 = 0
        let attr: NSDictionary? = try? FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
        if let _attr = attr {
            fileSize = _attr.fileSize()
        }
        
        cacheSizeLabel.text = covertToFileString(with: fileSize)
        
        
        cleanCache.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: {[weak self] (_) in
                guard let userId = LSLUser.current().token?.userId else { return }
                
                let deleteDb = self?.diskStorage.deleteDataBy(id: userId)
                print("数据库网络缓存文件删除:\(deleteDb ?? false ? "成功" : "失败")")
                self?.indicatorView.startAnimating()
                self?.cacheSizeLabel.text = nil
            })
            .disposed(by: rx.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.indicatorView.stopAnimating()
        }
        
        privacyAndService.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: {[weak self] (_) in
                let privacyAndUseVC: PrivacyAndUseController = ViewLoader.Storyboard.controller(from: "My")
                self?.navigationController?.pushViewController(privacyAndUseVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}
