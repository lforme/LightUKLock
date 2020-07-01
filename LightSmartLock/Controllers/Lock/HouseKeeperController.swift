//
//  HouseKeeperController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/6/17.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout
import RxCocoa
import RxSwift
import PKHUD
import RxDataSources

class HouseKeeperController: UIViewController, NavigationSettingStyle {
    
    @IBOutlet weak var fakerContainer: UIStackView!
    @IBOutlet weak var contactContainer: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var contactCollectionView: UICollectionView!
    
    let listDataSource = BehaviorRelay<[HouseKeeperModel]>(value: [])
    
    var cvDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, HouseKeeperModel>>!
    
    var backgroundColor: UIColor? {
        return ColorClassification.navigationBackground.value
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的管家"
        setupUI()
        bind()
        fetchData()
        setupObserver()
    }
    
    func setupUI() {
        contactContainer.setCircular(radius: 7)
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        alignedFlowLayout.scrollDirection = .horizontal
        alignedFlowLayout.minimumLineSpacing = 8
        alignedFlowLayout.minimumInteritemSpacing = 8
        alignedFlowLayout.itemSize = CGSize(width: 80, height: 120)
        contactCollectionView.contentInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        contactCollectionView.collectionViewLayout = alignedFlowLayout
        contactCollectionView.emptyDataSetSource = self
        contactCollectionView.register(UINib(nibName: "HouseKeeperCell", bundle: nil), forCellWithReuseIdentifier: "HouseKeeperCell")
    }
    
    func setupObserver() {
        NotificationCenter.default.rx.notification(.refreshState).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (notiObjc) in
            guard let refreshType = notiObjc.object as? NotificationRefreshType else { return }
            switch refreshType {
            case .steward:
                self?.fetchData()
            default: break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        
        let fakeTap = UITapGestureRecognizer(target: self, action: #selector(HouseKeeperController.fekeTap))
        fakerContainer.addGestureRecognizer(fakeTap)
        
        cvDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, HouseKeeperModel>>(configureCell: { (ds, cv, ip, item) -> HouseKeeperCell in
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "HouseKeeperCell", for: ip) as! HouseKeeperCell
            cell.name.text = item.username
            cell.avatar.setUrl(item.avatar)
            return cell
        })
        
        listDataSource.map {
            [SectionModel(model: "管家列表首页", items: $0)]
        }
        .bind(to: contactCollectionView.rx.items(dataSource: cvDataSource))
        .disposed(by: rx.disposeBag)
        
        contactCollectionView.rx
            .modelSelected(HouseKeeperModel.self)
            .subscribe(onNext: { (item) in
                guard let phone = item.phone else { return }
                if let phoneCallURL = URL(string: "tel://\(phone)") {
                    let application:UIApplication = UIApplication.shared
                    if (application.canOpenURL(phoneCallURL)) {
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        detailButton.rx
            .tap
            .subscribe(onNext: {[weak self] (_) in
                let houseKeeperListVC: HouseKeeperListController = ViewLoader.Storyboard.controller(from: "Home")
                self?.navigationController?.pushViewController(houseKeeperListVC, animated: true)
            }).disposed(by: rx.disposeBag)
    }
    
    func fetchData() {
        BusinessAPI.requestMapJSONArray(.stewardList(pageIndex: 1, pageSize: 15), classType: HouseKeeperModel.self, useCache: true, isPaginating: true)
            .map { $0.compactMap { $0 } }
            .catchErrorJustReturn([])
            .bind(to: listDataSource)
            .disposed(by: rx.disposeBag)
    }
    
    @objc func fekeTap() {
        HUD.flash(.label("请联系你的管家"), delay: 2)
    }
}
