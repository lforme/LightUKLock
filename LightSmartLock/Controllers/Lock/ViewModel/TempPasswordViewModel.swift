//
//  TempPasswordViewModel.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PKHUD
import SwiftEntryKit
import Action

final class TempPasswordViewModel: ListViewModeling {
    
    typealias Item = TempPasswordListModel
    
    enum PasswordType {
        case single
        case multiple
    }
    
    var refreshStatus: Observable<UKRefreshStatus> {
        return _refreshStatus.asObservable()
    }
    
    var list: Observable<[TempPasswordListModel]> {
        return _list.asObservable()
    }
    
    var pageIndex: Int = 1
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let passwordType: PasswordType
    
    let _list = BehaviorSubject<[TempPasswordListModel]>(value: [])
    let _refreshStatus = BehaviorRelay<UKRefreshStatus>(value: .none)
    
    init(type: PasswordType) {
        self.passwordType = type
    }
    
    func refresh() {
        pageIndex = 1
        guard let lockId = LSLUser.current().scene?.ladderLockId else {
            HUD.flash(.label("无法从服务器获取门锁编号, 请稍后再试"), delay: 2)
            return
        }
        
        switch passwordType {
        case .multiple:
            
            BusinessAPI.requestMapJSONArray(.getTempPasswordList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: TempPasswordListModel.self, isPaginating: true).subscribe(onNext: {[weak self] (originalValue) in
                let items = originalValue.filter { $0?.type == .some(.multiple) }.compactMap { $0 }
                self?._list.onNext(items)
                }, onError: {[weak self] (error) in
                    self?._list.onError(error)
                    self?._refreshStatus.accept(.endHeaderRefresh)
                }, onCompleted: {[weak self] in
                    self?._refreshStatus.accept(.endHeaderRefresh)
            }).disposed(by: disposeBag)
            
        case .single:
            BusinessAPI.requestMapJSONArray(.getTempPasswordList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: TempPasswordListModel.self, isPaginating: true).subscribe(onNext: {[weak self] (originalValue) in
                let items = originalValue.filter { $0?.type == .some(.single) }.compactMap { $0 }
                self?._list.onNext(items)
                }, onError: {[weak self] (error) in
                    self?._list.onError(error)
                    self?._refreshStatus.accept(.endHeaderRefresh)
                }, onCompleted: {[weak self] in
                    self?._refreshStatus.accept(.endHeaderRefresh)
            }).disposed(by: disposeBag)
            
        }
    }
    
    func loadMore() {
        pageIndex += 1
        guard let lockId = LSLUser.current().scene?.ladderLockId else {
            HUD.flash(.label("无法从服务器获取门锁编号, 请稍后再试"), delay: 2)
            return
        }
        
        switch passwordType {
        case .multiple:
            BusinessAPI.requestMapJSONArray(.getTempPasswordList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: TempPasswordListModel.self).map { (originalValue) -> [TempPasswordListModel] in
                let mutiplePwds = originalValue.filter { $0?.type == .some(.multiple) }.compactMap { $0 }
                return mutiplePwds
            }.subscribe(onNext: {[weak self] (models) in
                guard let this = self else { return }
                this._refreshStatus.accept(.endFooterRefresh)
                if models.count != 0 {
                    this._list.onNext(try! this._list.value() + models)
                } else {
                    this._refreshStatus.accept(.noMoreData)
                }
                }, onError: {[weak self] (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                    self?._refreshStatus.accept(.endFooterRefresh)
            }).disposed(by: disposeBag)
            
            
        case .single:
            BusinessAPI.requestMapJSONArray(.getTempPasswordList(lockId: lockId, pageIndex: pageIndex, pageSize: 15), classType: TempPasswordListModel.self).map { (originalValue) -> [TempPasswordListModel] in
                let mutiplePwds = originalValue.filter { $0?.type == .some(.single) }.compactMap { $0 }
                return mutiplePwds
            }.subscribe(onNext: {[weak self] (models) in
                guard let this = self else { return }
                this._refreshStatus.accept(.endFooterRefresh)
                if models.count != 0 {
                    this._list.onNext(try! this._list.value() + models)
                } else {
                    this._refreshStatus.accept(.noMoreData)
                }
                }, onError: {[weak self] (error) in
                    PKHUD.sharedHUD.rx.showError(error)
                    self?._refreshStatus.accept(.endFooterRefresh)
            }).disposed(by: disposeBag)
        }
    }
    
    func showLogView(_ model: Item) {
        guard let id = model.id else {
            HUD.flash(.label("无法从服务器获取Id, 请稍后再试"), delay: 2)
            return
        }
        BusinessAPI.requestMapJSON(.getTempPasswordLog(id: id), classType: TempPasswordRecordLog.self).subscribe(onNext: {[weak self] (model) in
            self?.setupPopLogView(model: model)
        }).disposed(by: disposeBag)
    }
    
    private func setupPopLogView(model: TempPasswordRecordLog) {
        var attributes = EKAttributes()
        attributes.name = "临时密码分享记录"
        attributes.windowLevel = .alerts
        attributes.position = .center
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.hapticFeedbackType = .success
        attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.4)))
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 0.7, initialVelocity: 0)
            ),
            scale: .init(
                from: 0.7,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
        attributes.positionConstraints.size = .init(
            width: .offset(value: 16),
            height: .constant(value: 440)
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)),
            height: .intrinsic
        )
        
        var logView: TempPasswordLogView = ViewLoader.Xib.view()
        
        logView = logView.then({[weak self] (view) in
            if self?.passwordType == .multiple {
                view.kind = .multiple
            } else {
                view.kind = .single
            }
            
            view.dataSource = model.ladderTmpPasswordStatusVOList ?? []
            view.updateListModel(model)
            
            view.closedButton.rx.tap.subscribe(onNext: { (_) in
                SwiftEntryKit.dismiss()
            }).disposed(by: view.rx.disposeBag)
            
            let undoAction = CocoaAction(workFactory: { (_) -> Observable<Void> in
                //                return BusinessAPI.requestMapBool(.retractTempKeyShare(shareID: model.shareID)).flatMapLatest { (_) -> Observable<Void> in
                //                    return .just(())
                //                }
                return .empty()
            })
            view.undoButton.rx.action = undoAction
            
            undoAction.elements.subscribe(onNext: { (_) in
                SwiftEntryKit.dismiss()
            }).disposed(by: view.rx.disposeBag)
        })
        
        SwiftEntryKit.display(entry: logView, using: attributes)
    }
}
