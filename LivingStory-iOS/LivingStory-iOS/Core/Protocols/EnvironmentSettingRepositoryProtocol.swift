//
//  EnvironmentSettingRepositoryProtocol.swift
//  LivingStory-iOS
//
//  환경 세팅 config 영속화 인터페이스 (CoreData 구현 ↔ Mock 교체 가능).
//

import Foundation

protocol EnvironmentSettingRepositoryProtocol {
    /// 저장된 세팅 1건 조회 (없으면 nil — 첫 실행)
    func fetch() throws -> EnvironmentSettingProfile?
    /// 특정 집의 세팅 조회
    func fetch(homeID: UUID) throws -> EnvironmentSettingProfile?
    /// 세팅 저장 (homeID 기준 upsert, deviceConfigs 트리 전체 교체)
    func save(_ profile: EnvironmentSettingProfile) throws
}
