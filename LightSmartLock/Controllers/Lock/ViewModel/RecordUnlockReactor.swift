//
//  RecordUnlockReactor.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import HandyJSON
import PKHUD

final class RecordUnlockReactor: Reactor {
    
    enum Action {
        case filter(Int)
        case pullToRefresh(Int?)
        case pullUpLoading(Int?)
    }
    
    struct State {
        var filterType: Int
        var pageIndex: Int
        var requestFinished: Bool
        var noMoreData: Bool
        var dataList: [UnlockRecordModel]
    }
    
    enum Mutation {
        case setFilter(Int)
        case setPullUpLoading(Int)
        case setPullToRefresh(Int)
        case setRequestFinished(Bool)
        case setNoMoreData(Bool)
        case setRefreshList([UnlockRecordModel])
        case setLoadList([UnlockRecordModel])
    }
    
    let initialState: State
    
    private let lockId: String
    private let userId: String
    
    init(lockId: String, userId: String) {
        self.lockId = lockId
        self.userId = userId
        self.initialState = State(filterType: 1, pageIndex: 1, requestFinished: true, noMoreData: false, dataList: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .filter(type):
            let share = self.request(pageIndex: 1, filter: type)
            let list = share.map { res in
                Mutation.setRefreshList(res)
            }
            return Observable.concat([
                .just(.setFilter(type)),
                list
            ])
            
        case let .pullToRefresh(pageIndex):
            guard let index = pageIndex else {
                return .empty()
            }
            let share = self.request(pageIndex: index, filter: self.currentState.filterType)
            let pageMutation = Observable.just(Mutation.setPullToRefresh(index))
            let list = share.map {
                Mutation.setRefreshList($0)
            }
            let isFinished = share.map { _ in
                Mutation.setRequestFinished(true)
            }
            return Observable.concat([
                pageMutation,
                isFinished,
                list
            ])
            
        case let .pullUpLoading(pageIndex):
            guard let index = pageIndex else {
                return .empty()
            }
            let share = self.request(pageIndex: self.currentState.pageIndex, filter: self.currentState.filterType)
            
            let pageMutation = Observable.just(Mutation.setPullUpLoading(index))
            let list = share.map {
                Mutation.setLoadList($0)
            }
            let isFinished = share.map { _ in Mutation.setRequestFinished(true) }
            let noMore = share.map  {
                Mutation.setNoMoreData($0.count == 0)
            }
            
            return Observable.concat([
                pageMutation,
                isFinished,
                noMore,
                list
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setFilter(type):
            state.filterType = type
            
        case let .setPullToRefresh(page):
            state.pageIndex = page
            
        case let .setPullUpLoading(page):
            state.pageIndex += page
            
        case let .setRequestFinished(finished):
            state.requestFinished = finished
            
        case let .setNoMoreData(noMore):
            state.noMoreData = noMore
            
        case let .setRefreshList(list):
            state.dataList = list
            
        case let .setLoadList(list):
            state.dataList += list
            let sort = Set(state.dataList).sorted { (a, b) -> Bool in
                let aa = a.openTime?.toInt() ?? 0
                let bb = b.openTime?.toInt() ?? -1
                return aa > bb
            }
            state.dataList = sort
        }
        return state
    }
}

extension RecordUnlockReactor {
    
    fileprivate func request(pageIndex: Int, filter: Int) -> Observable<[UnlockRecordModel]> {
        
        return BusinessAPI.requestMapJSONArray(.getUnlockRecords(lockId: lockId, type: filter, userId: userId, pageIndex: pageIndex, pageSize: 15), classType: UnlockRecordModel.self, isPaginating: true)
            .map { $0.compactMap { $0 } }
            .share(replay: 1, scope: .forever)
            .do(onError: { (error) in
                PKHUD.sharedHUD.rx.showError(error)
            })
    }
}
