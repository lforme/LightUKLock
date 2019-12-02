//
//  MessageCenterViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/29.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift


final class MessageCenterReactor: Reactor {
    
    enum Action {
        case refreshBegin
        case loadMoreBegin
        case changeMessageType(Int)
    }
    
    struct State {
        var pageIndex: Int
        var IsNomoreData: Bool
        var requestFinish: Bool
        var messageType: Int
        var messageList: [CenterMessageModel]
    }
    
    enum Mutation {
        case setRefreshPageIndex(Int)
        case setLoadMorePageIndex(Int)
        case setRequestFinished(Bool)
        case setNomoreData(Bool)
        case setMessageType(Int)
        case setLoadMoreResult([CenterMessageModel])
        case setRefreshResult([CenterMessageModel])
    }
    
    let initialState: State
    
    init() {
        self.initialState = State(pageIndex: 1, IsNomoreData: false, requestFinish: true, messageType: 1, messageList: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .refreshBegin:
            if !self.currentState.requestFinish {
                return .empty()
            }
            
            let request = BusinessAPI.requestMapJSONArray(.getLockNotice(noticeType: [-1], noticeLevel: [-1], pageIndex: 1, pageSize: 15), classType: CenterMessageModel.self, useCache: true).map { $0.compactMap{ $0 } }.share(replay: 1, scope: .forever)
            
            return Observable.concat([
                .just(.setRefreshPageIndex(1)),
                .just(.setNomoreData(false)),
                request.map(Mutation.setRefreshResult),
                request.map { _ in Mutation.setRequestFinished(true) }
            ])
            
        case .loadMoreBegin:
            if !self.currentState.requestFinish {
                return .empty()
            }
            
            let request = BusinessAPI.requestMapJSONArray(.getLockNotice(noticeType: [-1], noticeLevel: [-1], pageIndex: self.currentState.pageIndex + 1, pageSize: 15), classType: CenterMessageModel.self, useCache: true).map { $0.compactMap{ $0 } }.share(replay: 1, scope: .forever)
            
            return Observable.concat([
                .just(.setLoadMorePageIndex(1)),
                request.map { _ in Mutation.setRequestFinished(true) },
                request.map({ (list) -> Mutation in
                    if list.count == 0 {
                        return Mutation.setNomoreData(true)
                    } else {
                        return Mutation.setNomoreData(false)
                    }
                }),
                request.map(Mutation.setLoadMoreResult)
            ])
            
        case .changeMessageType:
            return .empty()
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setRequestFinished(finished):
            state.requestFinish = finished
            
        case let .setNomoreData(noMore):
            state.IsNomoreData = noMore
            
        case let .setLoadMorePageIndex(index):
            state.pageIndex += index
            print(state.pageIndex)
        case let .setRefreshPageIndex(index):
            state.pageIndex = index
            
        case let .setRefreshResult(list):
            state.messageList = list
            
        case let .setLoadMoreResult(list):
            state.messageList += list
            
        case let .setMessageType(type):
            state.messageType = type
        }
        
        return state
    }
}
