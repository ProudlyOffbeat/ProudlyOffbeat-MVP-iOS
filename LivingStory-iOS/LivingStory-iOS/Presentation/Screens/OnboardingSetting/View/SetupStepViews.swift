//
//  SetupStepViews.swift
//  LivingStory-iOS
//
//  세팅 플로우 단계별 콘텐츠 (데이터 주입형 순수 View).
//

import SwiftUI

private let cardShape = RoundedRectangle(cornerRadius: 26, style: .continuous)
private var cardFill: Color { Color(uiColor: .tertiarySystemBackground) }

// MARK: - ① 집 선택

struct HomeSelectView: View {
    let homes: [HomeModel]
    @Binding var selectedID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(homes, id: \.id) { home in
                Button {
                    selectedID = home.id
                } label: {
                    HStack {
                        Text(home.name)
                            .font(.calloutRegular)        // Callout Regular
                            .foregroundStyle(.primary)    // Labels Primary
                        Spacer()
                        if selectedID == home.id {
                            Image(.checkmark)
                                .font(.body1SemiBold)
                                .foregroundStyle(Color.yellow60)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 12)
                    .frame(height: 56)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)          // 버튼 기본 파랑 틴트 제거 → 텍스트 색 그대로
                if home.id != homes.last?.id {
                    Divider().overlay(Color.white.opacity(0.08)).padding(.horizontal, 20)
                }
            }
        }
        .background(cardFill, in: cardShape)
    }
}

// MARK: - ②③ 조명/스피커 선택 (룸별 토글)

struct DeviceToggleListView: View {
    let rooms: [RoomModel]
    let enabledIDs: Set<UUID>
    let onToggle: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {        // 방 사이 32
            ForEach(rooms, id: \.id) { room in
                VStack(alignment: .leading, spacing: 8) {
                    Text(room.name)
                        .font(.labelMedium)               // Pretendard Medium 14
                        .foregroundStyle(.tertiary)       // Labels Tertiary
                        .padding(.leading, 4)

                    VStack(spacing: 0) {
                        ForEach(room.devices, id: \.id) { device in
                            HStack {
                                Text(device.name)
                                    .font(.calloutRegular)     // Callout Regular
                                    .foregroundStyle(.primary) // Labels Primary
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { enabledIDs.contains(device.id) },
                                    set: { _ in onToggle(device.id) }
                                ))
                                .labelsHidden()
                                .tint(Color.yellow0)
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 12)
                            .frame(height: 56)

                            if device.id != room.devices.last?.id {
                                Divider().overlay(Color.white.opacity(0.08)).padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(cardFill, in: cardShape)
                }
            }
        }
    }
}

// MARK: - ④ 아이 나이

struct AgeSelectView: View {
    @Binding var age: Int

    var body: some View {
        VStack(spacing: 36) {                                  // 표시 ↔ 슬라이더 거리 36
            HStack(alignment: .firstTextBaseline, spacing: 12) {  // 만 ↔ 숫자 12
                Text("만")
                    .font(.custom("Pretendard-Regular", size: 22))
                    .foregroundStyle(.secondary)               // Labels Secondary
                HStack(alignment: .firstTextBaseline, spacing: 0) {  // 13 ↔ 세 붙어있음
                    Text("\(age)")
                        .font(.custom("Pretendard-SemiBold", size: 66))
                        .tracking(-2.64)                       // 66 × -4%
                        .foregroundStyle(.primary)
                    Text("세")
                        .font(.custom("Pretendard-SemiBold", size: 28))
                        .foregroundStyle(.primary)             // Labels Primary
                }
            }

            VStack(spacing: 4) {
                Slider(
                    value: Binding(get: { Double(age) }, set: { age = Int($0.rounded()) }),
                    in: 0...13, step: 1
                )
                .tint(Color.yellow0)

                HStack {
                    Text("0세").font(.labelRegular).foregroundStyle(.secondary)
                    Spacer()
                    Text("13세").font(.labelRegular).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 40)
    }
}

// MARK: - ⑤ 읽어줄 시간

struct TimeSelectView: View {
    @Binding var time: Date

    var body: some View {
        WheelTimePicker(time: $time)         // 기본 휠 + 선택행 yellow60
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 26)        // 양측 26
            .padding(.top, 80)               // 헤더로부터 ≈120 (스캐폴드 40 + 80)
    }
}
