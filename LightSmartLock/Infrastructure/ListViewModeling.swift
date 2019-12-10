//
//  ListViewModeling.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol ListViewModeling {
    
    associatedtype Item
    
    var refreshStatus: Observable<UKRefreshStatus> { get }
    var list: Observable<[Item]> { get }
    var pageIndex: Int { set get }
    var disposeBag: DisposeBag { get }
    
    func refresh()
    func loadMore()
}
