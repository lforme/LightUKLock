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

final class RecordUnlockReactor: Reactor {
    
    enum Action {
        case refreshChange(Int)
        case loadMore(Int)
    }
    
    struct State {
        var pageIndex: Int
        var loadMoreFinished: Bool
        var requestFinished: Bool
        var recordList: [UnlockRecordModel]
    }
    
    enum Mutation {
        case setRefreshPageIndex(Int)
        case setLoadMorePageIndex(Int)
        case setLoadMoreFinished(Bool)
        case setRequestFinished(Bool)
        case setLoadMoreResult([UnlockRecordModel])
        case setRefreshResult([UnlockRecordModel])
    }
    
    let initialState: State
    
    private let userCode: String
    
    init(userCode: String) {
        self.userCode = userCode
        
        self.initialState = State(pageIndex: 1, loadMoreFinished: false, requestFinished: true, recordList: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .loadMore(index):
            
            if self.currentState.loadMoreFinished {
                return .just(.setLoadMoreFinished(true))
            }
            
            let request =  BusinessAPI.requestMapJSONArray(.getUnlockLog(userCodes: [self.userCode], beginTime: nil, endTime: nil, index: self.currentState.pageIndex + 1, pageSize: 15), classType: UnlockRecordModel.self, useCache: true).map { $0.compactMap { $0 } }.share(replay: 1, scope: .forever)
            
            return Observable.concat([
                .just(.setLoadMorePageIndex(index)),
                request.map({ (list) -> Mutation in
                    if list.count == 0 {
                        return Mutation.setLoadMoreFinished(true)
                    } else {
                        return Mutation.setLoadMoreFinished(false)
                    }
                }),
                request.map({ (list) -> Mutation in
                    return Mutation.setLoadMoreResult(list)
                }),
                request.map{ _ in Mutation.setRequestFinished(true) }
            ])
            
        case let .refreshChange(index):
            let request = BusinessAPI.requestMapJSONArray(.getUnlockLog(userCodes: [self.userCode], beginTime: nil, endTime: nil, index: index, pageSize: 15), classType: UnlockRecordModel.self, useCache: true).map { $0.compactMap { $0 } }.share(replay: 1, scope: .forever)
            
            return Observable.concat([
                .just(.setRefreshPageIndex(index)),
                .just(.setLoadMoreFinished(false)),
                request.map({ (list) -> Mutation in
                    return .setRefreshResult(list)
                }),
                request.map{ _ in Mutation.setRequestFinished(true) }
            ])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setLoadMoreFinished(finished):
            state.requestFinished = true
            state.loadMoreFinished = finished
            
        case let .setLoadMorePageIndex(index):
            state.pageIndex += index
            
        case let .setRefreshResult(list):
            state.requestFinished = true
            state.recordList = list
            
        case let .setLoadMoreResult(list):
            state.requestFinished = true
            state.recordList += list
            
        case let .setRefreshPageIndex(index):
            state.pageIndex = index
            
        case let .setRequestFinished(finished):
            state.requestFinished = finished
        }
        
        
        return state
    }
}
