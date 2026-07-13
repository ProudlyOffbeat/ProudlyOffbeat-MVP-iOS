//
//  EnvironmentSettingRepository.swift
//  LivingStory-iOS
//
//  환경 세팅 config의 CoreData 영속화.
//  - homeID 기준 upsert (집당 1건)
//  - save 시 deviceConfigs 트리를 통째로 교체 → "한 트랜잭션에 다 저장"
//

import Foundation
import CoreData

@MainActor
final class EnvironmentSettingRepository: EnvironmentSettingRepositoryProtocol {

    private let context: NSManagedObjectContext

    init() {
        self.context = PersistenceController.shared.context
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - 조회

    func fetch() throws -> EnvironmentSettingProfile? {
        let request = EnvironmentSettingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        return try context.fetch(request).first?.toProfile()
    }

    func fetch(homeID: UUID) throws -> EnvironmentSettingProfile? {
        try findEntity(homeID: homeID)?.toProfile()
    }

    // MARK: - 저장 (Upsert)

    func save(_ profile: EnvironmentSettingProfile) throws {
        let entity = try findEntity(homeID: profile.homeID) ?? EnvironmentSettingEntity(context: context)
        entity.update(with: profile, in: context)
        try context.save()
    }

    // MARK: - Private

    private func findEntity(homeID: UUID) throws -> EnvironmentSettingEntity? {
        let request = EnvironmentSettingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "homeID == %@", homeID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - Entity ↔ Domain Mapping

extension EnvironmentSettingEntity {

    func toProfile() -> EnvironmentSettingProfile {
        let configs = (deviceConfigs as? Set<DeviceConfigEntity>)?.map { $0.toConfig() } ?? []
        return EnvironmentSettingProfile(
            homeID: homeID ?? UUID(),
            childAge: Int(childAge),
            readingHour: Int(readingHour),
            readingMinute: Int(readingMinute),
            deviceConfigs: configs
        )
    }

    /// 도메인 → 엔티티. deviceConfigs는 통째로 교체(기존 삭제 후 재생성).
    func update(with profile: EnvironmentSettingProfile, in context: NSManagedObjectContext) {
        homeID = profile.homeID
        childAge = Int16(profile.childAge)
        readingHour = Int16(profile.readingHour)
        readingMinute = Int16(profile.readingMinute)
        updatedAt = Date()

        // 기존 트리 제거 (Cascade)
        if let existing = deviceConfigs as? Set<DeviceConfigEntity> {
            existing.forEach { context.delete($0) }
        }
        // 새 트리 생성
        for config in profile.deviceConfigs {
            let entity = DeviceConfigEntity(context: context)
            entity.deviceID = config.deviceID
            entity.roomID = config.roomID
            entity.kind = config.kind.rawValue
            entity.isEnabled = config.isEnabled
            entity.setting = self
        }
    }
}

extension DeviceConfigEntity {

    func toConfig() -> DeviceConfig {
        DeviceConfig(
            deviceID: deviceID ?? UUID(),
            roomID: roomID ?? UUID(),
            kind: HomeDeviceType(rawValue: kind ?? HomeDeviceType.light.rawValue) ?? .light,
            isEnabled: isEnabled
        )
    }
}
