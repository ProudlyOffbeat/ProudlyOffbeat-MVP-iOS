//
//  MockHomeData.swift
//  LivingStory-iOS
//
//  UI 테스트/QA용 가짜 홈 데이터. DEBUG 빌드에서만 컴파일된다.
//  집 2개: "우리집"(거실·안방 기기) + "사무실"(기기 없음 → 빈 상태 UI 확인).
//

#if DEBUG
import Foundation

enum MockHomeData {

    static func makeHomes() -> [HomeModel] {
        // 우리집 — 거실 3, 안방 3
        let livingRoom = RoomModel(
            name: "거실",
            id: id("A1"),
            devices: [
                DeviceModel(name: "거실 조명 1", id: id("D1"), isOn: true,  deviceType: .light,   percentage: 80),
                DeviceModel(name: "거실 조명 2", id: id("D2"), isOn: false, deviceType: .light,   percentage: 60),
                DeviceModel(name: "마샬 스피커", id: id("D3"), isOn: true,  deviceType: .speaker, percentage: 45)
            ]
        )
        let bedroom = RoomModel(
            name: "안방",
            id: id("A2"),
            devices: [
                DeviceModel(name: "나노리프 1",   id: id("D4"), isOn: false, deviceType: .light,   percentage: 50),
                DeviceModel(name: "아카라 조명 1", id: id("D5"), isOn: true,  deviceType: .light,   percentage: 100),
                DeviceModel(name: "마샬 스피커 2", id: id("D6"), isOn: false, deviceType: .speaker, percentage: 30)
            ]
        )
        let myHome = HomeModel(
            id: id("E1"),
            name: "우리집",
            state: .normal,
            rooms: [livingRoom, bedroom]
        )

        // 사무실 — 기기 없음 (빈 상태 UI)
        let office = HomeModel(
            id: id("E2"),
            name: "사무실",
            state: .noDevices,
            rooms: []
        )

        return [myHome, office]
    }

    /// 테스트 재현성을 위한 고정 UUID
    private static func id(_ suffix: String) -> UUID {
        let padded = suffix.padding(toLength: 12, withPad: "0", startingAt: 0)
        return UUID(uuidString: "00000000-0000-0000-0000-\(padded)") ?? UUID()
    }
}
#endif
