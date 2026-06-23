//
//  LightingAdjustSheet.swift
//  LivingStory-iOS
//
//  독서 중 조명 카드 [조정] → "조명 조정" 풀스크린 시트
//  - 채도 평면(Hue×Saturation, 폴라 색상환) / 색상 스와치 / 밝기 슬라이더
//  - 모든 조정은 ReadingViewModel의 실시간 반영 로직에 연결
//    (드래그 중: updateLighting 쓰로틀 전송, 손 뗌: commitLighting 즉시 전송)
//

import SwiftUI

struct LightingAdjustSheet: View {

    let viewModel: ReadingViewModel
    @Environment(\.dismiss) private var dismiss

    /// 시스템 ColorPicker(스포이드)용 바인딩 — Color ↔ HSB 변환
    private var customColorBinding: Binding<Color> {
        Binding(
            get: {
                let config = viewModel.lightingConfig ?? .default
                return Color(
                    hue: Double(config.hue) / 360,
                    saturation: Double(config.saturation) / 100,
                    brightness: Double(config.brightness) / 100
                )
            },
            set: { newColor in
                let hsb = newColor.hsbComponents
                viewModel.updateLighting(hue: hsb.hue, saturation: hsb.saturation)
                viewModel.commitLighting()
            }
        )
    }

    /// 밝기: 드래그 중 쓰로틀 전송, 손 뗌 시 즉시 전송
    private var brightnessBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.lightingConfig?.brightness ?? 50) },
            set: { viewModel.updateLighting(brightness: Int($0.rounded())) }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // 채도 평면 (Hue × Saturation)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(StringLiterals.Reading.saturation)
                            .font(.calloutRegular)
                            .foregroundStyle(Color(.secondaryLabel))

                        HueSaturationPlane(
                            config: viewModel.lightingConfig ?? .default,
                            onChange: { hue, sat in
                                viewModel.updateLighting(hue: hue, saturation: sat)
                            },
                            onCommit: { viewModel.commitLighting() }
                        )
                        .frame(height: 184)
                    }

                    swatchRow

                    BrightnessSliderRow(
                        value: brightnessBinding,
                        onEditingChanged: { editing in
                            if !editing { viewModel.commitLighting() }
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Color.backgroundSecondary)
            .navigationTitle(StringLiterals.Reading.lightingAdjustTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(.close) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Image(.checkmark) }
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Swatch Row

    private var swatchRow: some View {
        let current = viewModel.lightingConfig ?? .default
        return HStack(spacing: 14) {
            // 스포이드 — 시스템 ColorPicker로 정밀 커스텀 색 (well 위를 흰 원으로 덮음)
            ColorPicker(selection: customColorBinding, supportsOpacity: false) {
                EmptyView()
            }
            .labelsHidden()
            .frame(width: 38, height: 38)
            .overlay {
                Circle()
                    .fill(.white)
                    .overlay {
                        Image(.eyedropper)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    .allowsHitTesting(false)
            }

            // Gemini 추천 (✨)
            if let gemini = viewModel.geminiRecommendedLighting {
                SwatchDot(
                    config: gemini,
                    isSelected: current.isSameHue(as: gemini),
                    badge: .sparkles
                ) {
                    viewModel.applyGeminiRecommended()
                }
            }

            // 고정 색 프리셋
            ForEach(LightingSwatch.presets, id: \.hue) { swatch in
                SwatchDot(
                    config: swatch,
                    isSelected: current.isSameHue(as: swatch)
                ) {
                    viewModel.updateLighting(hue: swatch.hue, saturation: swatch.saturation)
                    viewModel.commitLighting()
                }
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Hue × Saturation Plane (Figma 색상환 그대로)

/// 2D 색상 평면 — Figma export(node 955:2310)의 코닉 그라데이션을 그대로 재현.
/// 중심 = 흰색(채도 0), 타원 가장자리로 갈수록 채도↑. 각도(노랑=위, 시계방향) = Hue.
/// 비주얼·노브·드래그 모두 동일한 스톱 테이블로 정렬 → 손가락 위치와 색 일치.
/// 드래그 중 onChange(연속 호출 → 실시간 반영), 손 뗌 시 onCommit.
private struct HueSaturationPlane: View {
    let config: LightingConfig
    let onChange: (_ hue: Int, _ saturation: Int) -> Void
    let onCommit: () -> Void

    /// Figma 코닉 그라데이션 표시 색 (9 스톱, location 0 = 노랑, 시계방향)
    private static let figmaStops: [Gradient.Stop] = [
        .init(color: Color(red: 0.906, green: 0.878, blue: 0.251), location: 0.0),
        .init(color: Color(red: 0.537, green: 0.906, blue: 0.263), location: 0.1305),
        .init(color: Color(red: 0.235, green: 0.910, blue: 0.522), location: 0.2513),
        .init(color: Color(red: 0.235, green: 0.792, blue: 0.906), location: 0.3574),
        .init(color: Color(red: 0.412, green: 0.290, blue: 0.910), location: 0.4939),
        .init(color: Color(red: 0.702, green: 0.243, blue: 0.835), location: 0.6344),
        .init(color: Color(red: 0.910, green: 0.251, blue: 0.231), location: 0.7506),
        .init(color: Color(red: 0.933, green: 0.667, blue: 0.235), location: 0.8760),
        .init(color: Color(red: 0.906, green: 0.878, blue: 0.251), location: 1.0)
    ]

    /// location ↔ Hue 매핑 control points (hue는 연속 증가하도록 언랩: 57…417)
    private static let huePoints: [(loc: Double, hue: Double)] = [
        (0.0, 57), (0.1305, 90), (0.2513, 145), (0.3574, 195),
        (0.4939, 252), (0.6344, 287), (0.7506, 360), (0.8760, 397), (1.0, 417)
    ]

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                // 각도 = Hue (노랑=위, 시계방향)
                AngularGradient(
                    gradient: Gradient(stops: Self.figmaStops),
                    center: .center,
                    angle: .degrees(-90)
                )
                // 중심 회색(#E4E4E4) → 88%에서 투명 = 중심 채도 0
                EllipticalGradient(
                    stops: [
                        .init(color: Color(white: 0.894), location: 0),
                        .init(color: Color(white: 0.894).opacity(0), location: 0.88)
                    ],
                    center: .center
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay { knob(in: size) }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let (hue, sat) = values(at: value.location, in: size)
                        onChange(hue, sat)
                    }
                    .onEnded { _ in onCommit() }
            )
        }
    }

    private func knob(in size: CGSize) -> some View {
        // hue → location → 각도(위 기준) → 타원 위 좌표
        let loc = Self.location(forHue: Double(config.hue))
        let deg = loc * 360 * .pi / 180
        let r = CGFloat(config.saturation) / 100
        let x = size.width / 2 + r * CGFloat(sin(deg)) * size.width / 2
        let y = size.height / 2 - r * CGFloat(cos(deg)) * size.height / 2
        return Circle()
            .fill(Color(
                hue: Double(config.hue) / 360,
                saturation: Double(config.saturation) / 100,
                brightness: 1
            ))
            .frame(width: 28, height: 28)
            .overlay(Circle().strokeBorder(.white, lineWidth: 3))
            .shadow(radius: 2)
            .position(x: x, y: y)
    }

    /// 드래그 좌표 → (hue 0~360, saturation 0~100). 타원 정규화 + 각도→hue.
    private func values(at point: CGPoint, in size: CGSize) -> (Int, Int) {
        let u = (point.x - size.width / 2) / (size.width / 2)
        let v = (point.y - size.height / 2) / (size.height / 2)
        // 위(north)=0, 시계방향 증가
        var deg = atan2(u, -v) * 180 / .pi
        if deg < 0 { deg += 360 }
        let hue = Int(Self.hue(forLocation: deg / 360).rounded()) % 360
        let sat = Int((min(hypot(u, v), 1) * 100).rounded())
        return (hue, sat)
    }

    // MARK: location ↔ hue 보간

    private static func hue(forLocation loc: Double) -> Double {
        let L = min(max(loc, 0), 1)
        for i in 0..<huePoints.count - 1 {
            let (l0, h0) = huePoints[i], (l1, h1) = huePoints[i + 1]
            if L >= l0 && L <= l1 {
                let t = (L - l0) / (l1 - l0)
                return (h0 + t * (h1 - h0)).truncatingRemainder(dividingBy: 360)
            }
        }
        return 57
    }

    private static func location(forHue hue360: Double) -> Double {
        var h = hue360
        if h < 57 { h += 360 }             // 0~57 → 360~417 로 언랩
        h = min(max(h, 57), 417)
        for i in 0..<huePoints.count - 1 {
            let (l0, h0) = huePoints[i], (l1, h1) = huePoints[i + 1]
            if h >= h0 && h <= h1 {
                let t = (h - h0) / (h1 - h0)
                return l0 + t * (l1 - l0)
            }
        }
        return 0
    }
}

// MARK: - Swatch Dot

private struct SwatchDot: View {
    let config: LightingConfig
    let isSelected: Bool
    var badge: SymbolLiterals?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(
                    hue: Double(config.hue) / 360,
                    saturation: Double(config.saturation) / 100,
                    brightness: 1
                ))
                .frame(width: 38, height: 38)
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(.white, lineWidth: 2.5)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if let badge {
                        Image(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(.black, in: Circle())
                            .offset(x: 3, y: -3)
                    }
                }
        }
    }
}

// MARK: - Brightness Slider Row

private struct BrightnessSliderRow: View {
    @Binding var value: Double
    let onEditingChanged: (Bool) -> Void

    private static let fill = LinearGradient(
        colors: [.yellow20, .green0],
        startPoint: .leading,
        endPoint: .trailing
    )

    private var tickValues: [Double] { (0..<5).map { Double($0) * 25 } }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(StringLiterals.Reading.brightness)
                    .font(.calloutRegular)
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("\(Int(value.rounded()))%")
                    .font(.calloutSemiBold)
                    .foregroundStyle(Color(.label))
            }

            Slider(
                value: $value,
                in: 0...100,
                label: { EmptyView() },
                ticks: {
                    SliderTick(tickValues[0])
                    SliderTick(tickValues[1])
                    SliderTick(tickValues[2])
                    SliderTick(tickValues[3])
                    SliderTick(tickValues[4])
                },
                onEditingChanged: onEditingChanged
            )
            .tint(Self.fill)
        }
    }
}

// MARK: - Swatch Presets

private enum LightingSwatch {
    /// Figma 스와치 색 구성 (밝기는 슬라이더로 별도 조정 → hue/saturation만 의미)
    static let presets: [LightingConfig] = [
        LightingConfig(hue: 140, saturation: 60, brightness: 80),  // green
        LightingConfig(hue: 220, saturation: 70, brightness: 80),  // blue
        LightingConfig(hue: 200, saturation: 45, brightness: 80),  // light blue
        LightingConfig(hue: 280, saturation: 55, brightness: 80),  // purple
        LightingConfig(hue: 30,  saturation: 75, brightness: 80)   // orange
    ]
}

// MARK: - Helpers

private extension LightingConfig {
    /// 스와치 선택 표시용 — 색상(hue) 근사 일치
    func isSameHue(as other: LightingConfig) -> Bool {
        abs(hue - other.hue) <= 6 && abs(saturation - other.saturation) <= 8
    }
}

private extension Color {
    /// 시스템 ColorPicker가 돌려준 Color → LightingConfig용 (hue 0~360, sat 0~100)
    var hsbComponents: (hue: Int, saturation: Int) {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Int((h * 360).rounded()), Int((s * 100).rounded()))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("조명 조정 시트") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            LightingAdjustSheet(
                viewModel: ReadingViewModel(
                    previewBook: .mockISBN,
                    state: .reading,
                    lightingConfig: LightingConfig(hue: 40, saturation: 70, brightness: 50),
                    musicCategory: .fairytale
                )
            )
        }
}
#endif
