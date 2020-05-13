//
//  SelectorFeesController.swift
//  LightSmartLock
//
//  Created by mugua on 2020/5/11.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout
import PKHUD

class SelectorFeesCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


class SelectorFeesController: UICollectionViewController {
    
    var dataSrouce = [FeesKindModel]()
    var didSelected: ((_ name: String, _ categoryId: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "费用选择"
        setupUI()
        bind()
    }
    
    func bind() {
        BusinessAPI.requestMapJSONArray(.costCategory, classType: FeesKindModel.self, useCache: true).subscribe(onNext: {[weak self] (list) in
            self?.dataSrouce = list.compactMap { $0 }
            self?.collectionView.reloadData()
            }, onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .justified, verticalAlignment: .center)
        alignedFlowLayout.minimumLineSpacing = 8
        alignedFlowLayout.minimumInteritemSpacing = 8
        alignedFlowLayout.estimatedItemSize = CGSize(width: 80, height: 80)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.collectionViewLayout = alignedFlowLayout
        collectionView.emptyDataSetSource = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSrouce.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectorFeesCell", for: indexPath) as! SelectorFeesCell
        
        let data = dataSrouce[indexPath.item]
        cell.name.text = data.name
        cell.iconView.setUrl(data.icon)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSrouce[indexPath.item]
        self.didSelected?(data.name ?? "", data.categoryCode ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
}
