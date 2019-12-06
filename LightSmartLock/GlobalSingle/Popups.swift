//
//  Popups.swift
//  LightSmartLock
//
//  Created by mugua on 2019/12/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Then
import RxCocoa
import RxSwift
import SwiftEntryKit
import Action

struct Popups {
    
    static func showSelect(title: String, indexTitleOne: String, IndexTitleTwo: String, content: String) -> Observable<Int> {
        
        return Observable.create { (observer) -> Disposable in
            var attributes = EKAttributes()
            attributes.name = title
            attributes.windowLevel = .alerts
            attributes.position = .center
            attributes.screenInteraction = .absorbTouches
            attributes.entryInteraction = .absorbTouches
            attributes.hapticFeedbackType = .success
            attributes.screenBackground = .visualEffect(style: .standard)
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
                height: .intrinsic
            )
            attributes.positionConstraints.maxSize = .init(
                width: .constant(value: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)),
                height: .intrinsic
            )
            var customView: SelectPopupView = ViewLoader.Xib.view()
            
            customView = customView.then({ (view) in

                view.titleLabel.text = title
                view.contentLabel.text = content
                view.indexOneButton.setTitle(indexTitleOne, for: UIControl.State())
                view.indexTwoButton.setTitle(IndexTitleTwo, for: UIControl.State())
                
                let confirmAction = Action<Void, Int> { (_) -> Observable<Int> in
                    let button = [view.indexTwoButton, view.indexOneButton].filter { ($0?.isSelected ?? false) }.last
                    guard let selectedButton = button else {
                        return .empty()
                    }
                    return .just(selectedButton!.tag)
                }
                
                view.confirmButton.rx.bind(to: confirmAction, input: ())
                
                confirmAction.elements.subscribe(onNext: { (index) in
                    observer.onNext(index)
                    observer.onCompleted()
                    SwiftEntryKit.dismiss()
                }).disposed(by: view.rx.disposeBag)
                
                view.cancelButton.rx.tap.subscribe(onNext: { (_) in
                    observer.onCompleted()
                    SwiftEntryKit.dismiss()
                }).disposed(by: view.rx.disposeBag)
                
            })
            
            SwiftEntryKit.display(entry: customView, using: attributes)
            return Disposables.create()
        }
    }
}
