//
//  ChildAgeSettingView.swift
//  LivingStory-iOS
//
//  아이 나이 설정 (디자인 897-4862) — UserData.childAge 연결됨
//

import SwiftUI

struct ChildAgeSettingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var age: Int = UserData.childAge // 저장값으로 초기화

    var body: some View {
        ZStack {
            Color.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                SettingIntro(
                    symbol: .childHands,
                    headline: StringLiterals.Setting.childAgeHeadline,
                    subtitle: StringLiterals.Setting.childAgeSubtitle
                )


                VStack(spacing: 36) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(StringLiterals.Setting.agePrefix)
                            .font(.display3Regular)
                            // Labels/Secondary (iOS 시스템색)
                            .foregroundStyle(Color(.secondaryLabel))
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(age)")
                                .font(.display1SemiBold)
                                .foregroundStyle(.white)
                            Text(StringLiterals.Setting.ageUnit)
                                .font(.display2SemiBold)
                                .foregroundStyle(.white)
                        }
                    }

                    AgeSlider(age: $age)
                }
                .padding(.horizontal, 30)
                .padding(.top, 120)

                Spacer()

                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    UserData.childAge = age
                    dismiss()
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
                                colors: [.yellow20, .green0],
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
                Text("0\(StringLiterals.Setting.ageUnit)")
                Spacer()
                Text("\(maxAge)\(StringLiterals.Setting.ageUnit)")
            }
            .font(.labelRegular)
            // Labels/Tertiary (iOS 시스템색)
            .foregroundStyle(Color(.tertiaryLabel))
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ChildAgeSettingView()
    }
}
#endif
