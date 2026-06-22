//
//  ReadingView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//

import SwiftUI

struct ReadingView: View {

    let coordinator: AppCoordinator
    @State var viewModel: ReadingViewModel

    @State private var isPulsing = false
    @State private var showStopAlert = false
    @State private var isFinishing = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.state == .reading {
                readingDoneLayout
            } else {
                settingLayout
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.book.bookTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    // 중단 시 체크 전환 인터랙션 동안엔 제목 숨김 (페이드 함께)
                    .opacity(isFinishing ? 0 : 1)
            }
        }
        .background { pulseBackground }
        .overlay {
            if isFinishing {
                CheckmarkTransitionView {
                    coordinator.showStopReading(
                        book: viewModel.book,
                        conversations: viewModel.conversations
                    )
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .alert(
            viewModel.state == .setting ? StringLiterals.Reading.stopSettingAlert : StringLiterals.Reading.stopReadingAlert,
            isPresented: $showStopAlert
        ) {
            Button(StringLiterals.Reading.close, role: .cancel) {}
            Button(StringLiterals.Reading.stop, role: .destructive) {
                viewModel.stopReading()
                if viewModel.state == .setting {
                    coordinator.pop()
                } else {
                    // 독서 종료: 체크 전환 인터랙션 후 StopReadingView로 이동
                    withAnimation(.easeInOut(duration: 0.25)) { isFinishing = true }
                }
            }
        } message: {
            if viewModel.state == .reading {
                Text(StringLiterals.Reading.stopReadingAlertMessage)
            }
        }
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: Binding(
                get: { viewModel.state == .error },
                set: { _ in }
            )
        ) {
            Button(StringLiterals.Reading.retry, role: .cancel) {
                Task { await viewModel.retry() }
            }
            Button(StringLiterals.Reading.close, role: .destructive) {
                coordinator.pop()
            }
        }
        .task {
            await viewModel.startSetup()
        }
    }

    // MARK: - Layouts

    /// 세팅 중 (·error): 중앙 아이콘 + 문구 + '환경 세팅 중지'
    private var settingLayout: some View {
        ZStack {
            // Figma: 콘텐츠 블록 = 화면 세로 중심 -30pt
            settingStatus
                .offset(y: -30)

            VStack {
                Spacer()
                actionButton
                    .padding(.horizontal, 20)
            }
        }
    }

    /// 세팅 완료(독서 중): 아이콘 + '환경 세팅 완료!' + 컨트롤 카드 + '그만 읽기'
    private var readingDoneLayout: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            doneStatus

            Spacer().frame(height: 52)

            ControlCard(viewModel: viewModel, lightingColor: lightingColor)
                .padding(.horizontal, 20)

            Spacer()

            actionButton
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Status Content

    private var settingStatus: some View {
        VStack(spacing: 28) {
            Image(.home)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .foregroundStyle(Color(.tertiaryLabel)) // Labels/Tertiary (iOS 시스템색)

            VStack(spacing: 12) {
                Text(StringLiterals.Reading.settingTitle)
                    .font(.body1Regular)
                    .foregroundStyle(.white)
                Text(StringLiterals.Reading.settingSubtitle)
                    .font(.body2Regular)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var doneStatus: some View {
        VStack(spacing: 28) {
            Image(.musicNoteHouse)
                .resizable()
                .scaledToFit()
                .frame(height: 72)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0x92CFB1), .green0, .yellow20],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 12) {
                Text(StringLiterals.Reading.settingDoneTitle)
                    .font(.body1Regular)
                    .foregroundStyle(.white)
                Text(StringLiterals.Reading.settingDoneSubtitle)
                    .font(.body2Regular)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .multilineTextAlignment(.center)
        }
    }

    private var actionButton: some View {
        PrimaryButtonSwiftUI(
            title: viewModel.state == .setting ? StringLiterals.Reading.stopSettingButton : StringLiterals.Reading.stopReadingButton
        ) {
            showStopAlert = true
        }
    }

    // MARK: - Helpers

    private var lightingColor: Color {
        guard let config = viewModel.lightingConfig else {
            return .yellow0
        }
        return Color(
            hue: Double(config.hue) / 360.0,
            saturation: Double(config.saturation) / 100.0,
            brightness: Double(config.brightness) / 100.0
        )
    }

    private var pulseBackground: some View {
        ZStack {
            // Figma: 세팅 화면 base = Backgrounds/Secondary, 독서 중은 몰입용 검정
            (viewModel.state == .setting ? Color.backgroundSecondary : Color.black)

            if viewModel.state == .setting {
                // Figma: 흰색 타원 글로우(610×610, 중앙), opacity 0↔100 왕복
                Circle()
                    .fill(
                        EllipticalGradient(
                            stops: [
                                .init(color: .white.opacity(0.2), location: 0),
                                .init(color: .white.opacity(0), location: 1)
                            ],
                            center: .center
                        )
                    )
                    .frame(width: 610, height: 610)
                    .opacity(isPulsing ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.5), value: viewModel.state)
            } else {
                EmptyView()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Control Card (조명 / 음악)

private struct ControlCard: View {
    let viewModel: ReadingViewModel
    let lightingColor: Color

    /// 채움 색(그라데이션). 네이티브 Slider tint로 넘기면 단색으로 뭉개질 수 있음(의도).
    private static let fill = LinearGradient(
        colors: [.yellow20, .green0],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// 밝기: 드래그 중 쓰로틀 전송(updateLighting), 손 뗌 시 즉시(commitLighting)
    private var brightnessBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.lightingConfig?.brightness ?? 50) },
            set: { viewModel.updateLighting(brightness: Int($0.rounded())) }
        )
    }

    /// 볼륨: 0~1 → audioPlayerService 즉시 반영
    private var volumeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.volume) },
            set: { viewModel.setVolume(Float($0)) }
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            EnvControlRow(
                symbol: .lightbulb,
                title: StringLiterals.Reading.lightingTitle,
                valueLabel: StringLiterals.Reading.brightness,
                value: brightnessBinding,
                range: 0...100,
                fill: Self.fill,
                onEditingChanged: { editing in
                    if !editing { viewModel.commitLighting() }
                }
            ) {
                Circle()
                    .fill(lightingColor)
                    .frame(width: 56, height: 56)
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 8)

            EnvControlRow(
                symbol: .speaker,
                title: StringLiterals.Reading.musicTitle,
                valueLabel: StringLiterals.Reading.volume,
                value: volumeBinding,
                range: 0...1,
                fill: Self.fill
            ) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xCCBFE5), Color(hex: 0x6E5BB8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(.waveform)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct EnvControlRow<Leading: View>: View {
    let symbol: SymbolLiterals
    let title: String
    let valueLabel: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let fill: LinearGradient
    var onEditingChanged: (Bool) -> Void = { _ in }
    @ViewBuilder let leading: () -> Leading

    private var percent: Int {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return Int((((value - range.lowerBound) / span) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(symbol)
                        .font(.system(size: 15, weight: .semibold))
                    Text(title)
                        .font(.body2Medium)
                }
                .foregroundStyle(.white)

                Spacer()

                AdjustPill()
            }

            HStack(spacing: 20) {
                leading()

                VStack(spacing: 0) {
                    HStack {
                        Text(valueLabel)
                            .font(.labelRegular)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("\(percent)%")
                            .font(.labelMedium)
                            .foregroundStyle(.white)
                    }

                    TickSlider(value: $value, in: range, fill: fill, onEditingChanged: onEditingChanged)
                }
            }
        }
    }
}

private struct AdjustPill: View {
    var body: some View {
        // 동작 보류 (시각 전용) — 추후 조정 화면 연동
        HStack(spacing: 4) {
            Image(.sliderHorizontal)
                .font(.system(size: 11, weight: .semibold))
            Text(StringLiterals.Reading.adjust)
                .font(.labelMedium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.fillTertiary, in: Capsule())
    }
}

/// 네이티브 Slider — iOS 26 `ticks:` 로 틱 기본 제공. (수제 오버레이 불필요)
/// tint에 그라데이션을 주지만 UISlider 브리지 특성상 단색으로 뭉개질 수 있음(의도).
private struct TickSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let fill: LinearGradient
    var onEditingChanged: (Bool) -> Void

    init(
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        fill: LinearGradient,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.range = range
        self.fill = fill
        self.onEditingChanged = onEditingChanged
    }

    /// 범위 양끝 포함 5개 틱 위치
    private var tickValues: [Double] {
        let lo = range.lowerBound
        let hi = range.upperBound
        return (0..<5).map { lo + (hi - lo) * Double($0) / 4 }
    }

    var body: some View {
        Slider(
            value: $value,
            in: range,
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
        .tint(fill)
    }
}

// MARK: - Colors (Figma 다크 토큰)

private extension Color {
    static let fillTertiary = Color(red: 118 / 255, green: 118 / 255, blue: 128 / 255).opacity(0.24)

    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("세팅 중") {
    NavigationStack {
        ReadingView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            viewModel: ReadingViewModel(previewBook: .mockISBN, state: .setting)
        )
    }
}

#Preview("독서 중") {
    NavigationStack {
        ReadingView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            viewModel: ReadingViewModel(
                previewBook: .mockISBN,
                state: .reading,
                lightingConfig: LightingConfig(hue: 40, saturation: 80, brightness: 70),
                musicCategory: .forest
            )
        )
    }
}
#endif
