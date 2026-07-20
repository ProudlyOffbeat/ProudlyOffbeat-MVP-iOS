//
//  HomeObservation.swift
//  LivingStory-iOS
//
//  공유 HomeDataProviding 구독 토큰. 소비처가 strong으로 보유하고, 화면이 사라지거나
//  더 이상 필요 없을 때 cancel()로 콜백을 끊는다. (공유 인스턴스 자체는 nil 하지 않음)
//  deinit 자동 해지는 두지 않는다 — 프로바이더가 owner를 weak로 잡아 dealloc 시 자동 프루닝하므로.
//

import Foundation

@MainActor
final class HomeObservation {
    private var onCancel: (() -> Void)?

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel?()
        onCancel = nil
    }
}
