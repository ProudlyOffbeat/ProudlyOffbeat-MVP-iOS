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
    @State private var showColorWheel = false
    
    var body: some View {
        VStack {
            Spacer()
            statusContent
            if viewModel.state == .reading {
                controlPanel
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
            }
            Spacer()
            actionButton
                .padding(.horizontal, 20)
        }
        .navigationTitle(viewModel.book.bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background { pulseBackground }
        .preferredColorScheme(.dark)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                    coordinator.showStopReading(bookTitle: viewModel.book.bookTitle, conversations: viewModel.conversations)
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
    
    // MARK: - Subviews
    
    private var statusContent: some View {
        VStack(spacing: 28) {
            Image(viewModel.state == .setting ? .home : .musicNoteHouse)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(height: 79)
                .id(viewModel.state)
            
            VStack(spacing: 6) {
                Text(viewModel.state == .setting ? StringLiterals.Reading.settingTitle : StringLiterals.Reading.settingDoneTitle)
                    .font(.bodyRegular)
                    .foregroundStyle(.white)
                Text(viewModel.state == .setting ? StringLiterals.Reading.settingSubtitle : StringLiterals.Reading.settingDoneSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .opacity(0.5)
                    .multilineTextAlignment(.center)
            }
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
    
    // MARK: - Control Panel
    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 반응 로그
            HStack {
                Text(viewModel.lastAction ?? "대기")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                if let ms = viewModel.lastLatencyMs {
                    Text("\(ms)ms")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            // 반응시간 통계 (latencyHistory 있을 때)
            if let avg = viewModel.avgLatencyMs,
               let minV = viewModel.minLatencyMs,
               let maxV = viewModel.maxLatencyMs {
                HStack(spacing: 14) {
                    latencyStat("평균", value: avg)
                    latencyStat("최소", value: minV)
                    latencyStat("최대", value: maxV)
                    Spacer()
                    Button {
                        viewModel.clearLatencyHistory()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.6))
            }

            // 볼륨
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.1.fill")
                    .foregroundStyle(.white)
                Slider(
                    value: Binding(
                        get: { viewModel.volume },
                        set: { viewModel.setVolume($0) }
                    ),
                    in: 0...1
                )
                .tint(.white)
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.white)
            }
            
            // 음악 카테고리 (가로 스크롤 10개 버튼)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MusicCategory.allCases, id: \.self) { category in
                        Button {
                            viewModel.changeMusic(to: category)
                        } label: {
                            Text(category.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    viewModel.musicCategory == category
                                    ? Color.white.opacity(0.35)
                                    : Color.white.opacity(0.12)
                                )
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // 조명 프리셋 팔레트 + 커스텀 색상환
            HStack(spacing: 10) {
                // Gemini 추천 버튼 (있을 때만)
                if let geminiConfig = viewModel.geminiRecommendedLighting {
                    Button {
                        viewModel.applyGeminiRecommended()
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(
                                    Color(
                                        hue: Double(geminiConfig.hue) / 360.0,
                                        saturation: Double(geminiConfig.saturation) / 100.0,
                                        brightness: Double(geminiConfig.brightness) / 100.0
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(.yellow, lineWidth: 2)
                                )
                            Text("AI")
                                .font(.caption2)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                ForEach(LightingPreset.allCases, id: \.self) { preset in
                    Button {
                        viewModel.applyPreset(preset)
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(preset.previewColor)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                            Text(preset.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // 커스텀 원형 색상환 (탭 시 sheet로 열림)
                Button {
                    showColorWheel = true
                } label: {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                                    center: .center
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.4), lineWidth: 1)
                            )
                        Text("커스텀")
                            .font(.caption2)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showColorWheel) {
                ColorWheelSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }

            // 밝기 (손 뗄 때 즉시 전송)
            HStack(spacing: 10) {
                Image(systemName: "sun.min.fill")
                    .foregroundStyle(.white)
                Slider(
                    value: Binding(
                        get: { Double(viewModel.lightingConfig?.brightness ?? 80) },
                        set: { viewModel.updateLighting(brightness: Int($0)) }
                    ),
                    in: 10...100,
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            viewModel.commitLighting()  // 손 뗐을 때 즉시 전송
                        }
                    }
                )
                .tint(.white)
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func latencyStat(_ label: String, value: Int) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.white.opacity(0.4))
            Text("\(value)ms")
                .foregroundStyle(.white.opacity(0.85))
        }
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

// MARK: - LightingPreset Preview Color

extension LightingPreset {
    var previewColor: Color {
        let c = config
        return Color(
            hue: Double(c.hue) / 360.0,
            saturation: Double(c.saturation) / 100.0,
            brightness: Double(c.brightness) / 100.0
        )
    }
}

// MARK: - Color Wheel Sheet

struct ColorWheelSheet: View {
    let viewModel: ReadingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // 헤더 (제목 + 적용 버튼)
            HStack {
                Text("색상 선택")
                    .font(.headline)
                Spacer()
                Button("적용") {
                    viewModel.commitLighting()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // 원형 색상환
            CircularColorWheel(
                hue: Double(viewModel.lightingConfig?.hue ?? 0),
                saturation: Double(viewModel.lightingConfig?.saturation ?? 0),
                onChange: { newHue, newSat in
                    viewModel.updateLighting(hue: newHue, saturation: newSat)
                }
            )
            .frame(width: 320, height: 320)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Circular Color Wheel

struct CircularColorWheel: View {
    let hue: Double         // 0-360
    let saturation: Double  // 0-100
    let onChange: (Int, Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2

            ZStack {
                // 1. 색상환 (각도별 Hue)
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .red, .yellow, .green, .cyan, .blue, .purple, .red
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        )
                    )

                // 2. 채도 그라디언트 (중심은 흰색)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: radius
                        )
                    )

                // 3. 현재 위치 표시 인디케이터
                let angleRad = hue * .pi / 180.0
                let distance = (saturation / 100.0) * radius
                let indicatorX = radius + CGFloat(distance * cos(angleRad))
                let indicatorY = radius + CGFloat(distance * sin(angleRad))

                Circle()
                    .strokeBorder(.white, lineWidth: 3)
                    .background(Circle().fill(.clear))
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .position(x: indicatorX, y: indicatorY)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dx = value.location.x - radius
                        let dy = value.location.y - radius
                        let dist = sqrt(dx * dx + dy * dy)

                        // 반지름 밖 터치는 원 가장자리로 클램프
                        let clampedDist = min(dist, radius)

                        // 각도 계산 (0도 = 오른쪽, 시계방향)
                        var angle = atan2(dy, dx) * 180 / .pi
                        if angle < 0 { angle += 360 }

                        let hueDeg = Int(angle) % 360
                        let satPercent = Int((clampedDist / radius) * 100)

                        onChange(hueDeg, satPercent)
                    }
            )
        }
    }
}
