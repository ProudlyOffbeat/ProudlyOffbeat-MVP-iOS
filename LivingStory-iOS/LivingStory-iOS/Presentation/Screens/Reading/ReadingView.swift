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
            header

            if viewModel.state == .reading {
                readingDoneLayout
            } else {
                settingLayout
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
            Button("재시도", role: .cancel) {
                Task { await viewModel.retry() }
            }
            Button("닫기", role: .destructive) {
                coordinator.pop()
            }
        }
        .task {
            await viewModel.startSetup()
        }
    }

    // MARK: - Layouts

    /// 커스텀 헤더 (책 제목) — 전역 네비바를 숨기므로 navigationTitle 대신 직접 표시
    private var header: some View {
        Text(viewModel.book.bookTitle)
            .font(.headlineRegular)
            .foregroundStyle(.white)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
    }

    /// 세팅 중 (·error): 중앙 아이콘 + 문구 + '환경 세팅 중지'
    private var settingLayout: some View {
        VStack {
            Spacer()
            settingStatus
            Spacer()
            actionButton
                .padding(.horizontal, 20)
        }
    }

    /// 세팅 완료(독서 중): 아이콘 + '환경 세팅 완료!' + 컨트롤 카드 + '그만 읽기'
    private var readingDoneLayout: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            doneStatus

            Spacer().frame(height: 52)

            ControlCard(
                lightingColor: lightingColor,
                brightness: viewModel.lightingConfig?.brightness ?? 50
            )
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
                .frame(height: 79)
                .foregroundStyle(.white.opacity(0.22))

            VStack(spacing: 6) {
                Text(StringLiterals.Reading.settingTitle)
                    .font(.bodyRegular)
                    .foregroundStyle(.white)
                Text(StringLiterals.Reading.settingSubtitle)
                    .font(.subheadlineRegular)
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
                        colors: [Color(hex: 0x92CFB1), Color(hex: 0xBFEE68), Color(hex: 0xFFCB24)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 12) {
                Text(StringLiterals.Reading.settingDoneTitle)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                Text(StringLiterals.Reading.settingDoneSubtitle)
                    .font(.system(size: 18))
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
        .environment(\.colorScheme, .dark)
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
            Color.black
            Circle()
                .fill(
                    RadialGradient(
                        colors: viewModel.state == .setting
                            ? [.yellow0, .yellow20, .clear]
                            : [lightingColor, lightingColor.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 305
                    )
                )
                .frame(width: 610, height: 610)
                .scaleEffect(isPulsing ? 1.0 : 0.85)
                .opacity(isPulsing ? 0.4 : 0.1)
                .blur(radius: 50)
                .animation(.easeInOut(duration: 1.5), value: viewModel.state)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Control Card (조명 / 음악)

private struct ControlCard: View {
    let lightingColor: Color
    let brightness: Int

    var body: some View {
        VStack(spacing: 16) {
            EnvControlRow(
                systemImage: "lightbulb.fill",
                title: "조명",
                valueLabel: "밝기",
                percentText: "\(brightness)%",
                fraction: Double(brightness) / 100.0
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
                systemImage: "speaker.wave.2.fill",
                title: "음악",
                valueLabel: "볼륨",
                percentText: "50%",          // 추천 볼륨 데이터 없음 → 고정 더미
                fraction: 0.5
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
                        Image(systemName: "waveform")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct EnvControlRow<Leading: View>: View {
    let systemImage: String
    let title: String
    let valueLabel: String
    let percentText: String
    let fraction: Double
    @ViewBuilder let leading: () -> Leading

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
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
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(percentText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    EnvSlider(fraction: fraction)
                }
            }
        }
    }
}

private struct AdjustPill: View {
    var body: some View {
        // 동작 보류 (시각 전용) — 추후 조정 화면 연동
        HStack(spacing: 4) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 11, weight: .semibold))
            Text("조정")
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.fillTertiary, in: Capsule())
    }
}

/// 비상호작용 슬라이더 (추천값 표시 전용)
private struct EnvSlider: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let f = min(max(fraction, 0), 1)

            ZStack {
                // 눈금 5개 (트랙 아래)
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 4, height: 4)
                        if index < 4 { Spacer(minLength: 0) }
                    }
                }
                .offset(y: 9)

                // 트랙
                Capsule()
                    .fill(Color.fillPrimary)
                    .frame(height: 6)

                // 채움 (값 비율)
                HStack(spacing: 0) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xFFCB24), Color(hex: 0xBFEE68)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: w * f, height: 6)
                    Spacer(minLength: 0)
                }

                // 노브
                Capsule()
                    .fill(.white)
                    .frame(width: 30, height: 28)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                    .position(x: min(max(w * f, 15), w - 15), y: geo.size.height / 2)
            }
        }
        .frame(height: 50)
    }
}

// MARK: - Colors (Figma 다크 토큰)

private extension Color {
    static let fillTertiary = Color(red: 118 / 255, green: 118 / 255, blue: 128 / 255).opacity(0.24)
    static let fillPrimary = Color(red: 120 / 255, green: 120 / 255, blue: 128 / 255).opacity(0.36)

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
