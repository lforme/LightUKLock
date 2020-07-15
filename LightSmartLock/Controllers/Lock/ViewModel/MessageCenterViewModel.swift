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
        case refreshBegin(Int?)
        case loadMoreBegin(Int?)
        case changeMessageType(Int?)
    }
    
    struct State {
        var pageIndex: Int
        var isNoMoreData: Bool
        var isFinished: Bool
        var messageType: Int
        var messageList: [CenterMessageModel]
    }
    
    enum Mutation {
        case setRefreshPageIndex(Int)
        case setLoadMorePageIndex(Int)
        case setRequestFinished(Bool)
        case setNoMoreData(Bool)
        case setMessageType(Int)
        case setLoadMoreResult([CenterMessageModel])
        case setRefreshResult([CenterMessageModel])
    }
    
    let initialState: State
    let assetId: String
    
    init(assetId: String) {
        self.assetId = assetId
        self.initialState = State(pageIndex: 1, isNoMoreData: false, isFinished: true, messageType: 1, messageList: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .refreshBegin(page):
            guard let index = page else {
                return .empty()
            }
            let share = requset(pageIndex: index, type: self.currentState.messageType)
            
            let pageIndex = Observable.just(Mutation.setRefreshPageIndex(index))
            
            let finished = share.map { _ in
                Mutation.setRequestFinished(true)
            }
            
            let list = share.map { items in
                Mutation.setRefreshResult(items)
            }
            
            return Observable.concat([finished, pageIndex, list])
            
        case let .loadMoreBegin(page):
          
            guard let index = page else {
                return .empty()
            }
            
            let share = requset(pageIndex: self.currentState.pageIndex, type: self.currentState.messageType)
            
            let finished = share.map { _ in
                Mutation.setRequestFinished(true)
            }
            
            let noMore = share.map { items in
                Mutation.setNoMoreData(items.count == 0)
            }
            
            let list = share.map { items in
                Mutation.setLoadMoreResult(items)
            }
            
            let pageIndex = Observable.just(Mutation.setLoadMorePageIndex(index))
            
            return Observable.concat([
                finished, noMore, list, pageIndex
            ])
            
        case let .changeMessageType(type):
            guard let t = type else {
                return .empty()
            }
            
            let share = requset(pageIndex: currentState.pageIndex, type: t)
            
            let finished = share.map { _ in
                Mutation.setRequestFinished(true)
            }
            
            let list = share.map { items in
                Mutation.setRefreshResult(items)
            }
            
            return Observable.concat([finished, list])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setRequestFinished(finished):
            state.isFinished = finished
            
        case let .setNoMoreData(noMore):
            state.isNoMoreData = noMore
            
        case let .setLoadMorePageIndex(index):
            state.pageIndex += index
            
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
    
    func requset(pageIndex: Int, type: Int) -> Observable<[CenterMessageModel]> {
        
        return BusinessAPI.requestMapJSONArray(.messageList(assetId: assetId, smsType: type, pageIndex: pageIndex, pageSize: 15), classType: CenterMessageModel.self, useCache: true, isPaginating: true)
            .map { $0.compactMap{ $0 } }
            .share(replay: 1, scope: .forever)
    }
}
