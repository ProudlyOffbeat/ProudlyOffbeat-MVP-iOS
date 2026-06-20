//
//  ChildAgeSettingView.swift
//  LivingStory-iOS
//
//  아이 나이 설정 (디자인 897-4862) — 현재 UI만, 값 더미
//

import SwiftUI

struct ChildAgeSettingView: View {
    let coordinator: AppCoordinator

    @State private var age: Int = 13 // 더미 기본값

    var body: some View {
        ZStack {
            Color(hex: 0x1C1C1E).ignoresSafeArea()

            VStack(spacing: 0) {
                SettingIntro(
                    systemImage: "figure.and.child.holdinghands",
                    headline: StringLiterals.Setting.childAgeHeadline,
                    subtitle: StringLiterals.Setting.childAgeSubtitle
                )


                VStack(spacing: 36) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("만")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(white: 0.92).opacity(0.7))
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(age)")
                                .font(.system(size: 66, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("세")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }

                    AgeSlider(age: $age)
                }
                .padding(.horizontal, 30)
                .padding(.top, 120)

                Spacer()

                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    coordinator.pop()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .navigationTitle(StringLiterals.Setting.childAgeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Age Slider (0 ~ 13세)

private struct AgeSlider: View {
    @Binding var age: Int
    private let maxAge = 13
    private let knobWidth: CGFloat = 38
    private let knobOverhang: CGFloat = 10 // 최댓값에서 트랙 끝에 살짝 걸치는 양

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                let frac = CGFloat(age) / CGFloat(maxAge)

                ZStack(alignment: .leading) {
                    // 트랙
                    Capsule()
                        .fill(Color(red: 120/255, green: 120/255, blue: 128/255).opacity(0.36))
                        .frame(height: 6)

                    // 채움 (좌 노랑 → 우 연두)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xFFCB24), Color(hex: 0xBFEE68)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, w * frac), height: 6)

                    // 눈금 5개 — 트랙 아래
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle().fill(Color.white.opacity(0.3)).frame(width: 4, height: 4)
                            if index < 4 { Spacer(minLength: 0) }
                        }
                    }
                    .offset(y: 12)

                    // 노브
                    Capsule()
                        .fill(.white)
                        .frame(width: knobWidth, height: 24)
                        .shadow(color: .black.opacity(0.18), radius: 6, y: 4)
                        .offset(x: -knobOverhang + (w - knobWidth + knobOverhang * 2) * frac)
                }
                .frame(height: 50)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = min(max(0, value.location.x), w)
                            age = Int((x / w * CGFloat(maxAge)).rounded())
                        }
                )
            }
            .frame(height: 50)

            HStack {
                Text("0세")
                Spacer()
                Text("\(maxAge)세")
            }
            .font(.system(size: 14))
            .foregroundStyle(Color(white: 0.92).opacity(0.3))
        }
    }
}

// MARK: - Color Helper

private extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ChildAgeSettingView(coordinator: AppCoordinator(navigationController: UINavigationController()))
    }
}
#endif
