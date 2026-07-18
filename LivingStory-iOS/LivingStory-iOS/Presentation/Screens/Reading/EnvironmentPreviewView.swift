//
//  EnvironmentPreviewView.swift
//  LivingStory-iOS
//
//  환경 미리보기 — 바코드 인식중에 받아온 Gemini 추천 조명·음악을 실제로 적용한 채 보여주고,
//  "조정"으로 세부 시트(조명/음악 조정)를 열거나, 밝기·볼륨 퍼센트를 탭해 홈앱처럼
//  세로 슬라이더(퍼센트 위에 표시)로 실시간 조절한 뒤 "책 환경 세팅하기"로 독서에 진입한다.
//

import SwiftUI

struct EnvironmentPreviewView: View {

    let viewModel: ReadingViewModel
    let onStart: () -> Void
    let onAdjustLighting: () -> Void
    let onAdjustMusic: () -> Void

    private enum ActiveOverlay { case brightness, volume }
    @State private var activeOverlay: ActiveOverlay?

    private let secondary = Color(hex: 0xEBEBF5, alpha: 0.7)

    private var brightnessBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.lightingConfig?.brightness ?? 50) / 100 },
            set: { viewModel.updateLighting(brightness: Int(($0 * 100).rounded())) }
        )
    }
    private var volumeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.volume) },
            set: { viewModel.setVolume(Float($0)) }
        )
    }

    private var lightingColor: Color {
        let c = viewModel.lightingConfig ?? .default
        return Color(hue: Double(c.hue) / 360, saturation: Double(c.saturation) / 100, brightness: 1)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 32) {
                bookSection
                HStack(alignment: .top, spacing: 16) {
                    lightingCard
                    musicCard
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // 앱 표준 리퀴드 글래스 CTA (clear — "홈으로" 등과 동일, 검정이라 안 보이던 문제 해결)
            PrimaryButtonSwiftUI(title: StringLiterals.Reading.setupButton, action: onStart)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
        }
        // AI 추천 실패 시 에러별 알럿 — 다시 추천받기 / 기본 환경으로 진행
        .alert("AI 추천을 못 받았어요", isPresented: Binding(
            get: { viewModel.aiFallbackMessage != nil },
            set: { if !$0 { viewModel.aiFallbackMessage = nil } }
        )) {
            Button("다시 추천받기") {
                Task { await viewModel.retryAIRecommendation() }
            }
            Button("기본 환경으로 진행", role: .cancel) {
                viewModel.aiFallbackMessage = nil
            }
        } message: {
            Text(viewModel.aiFallbackMessage ?? "")
        }
    }

    // MARK: - Book

    private var bookSection: some View {
        VStack(spacing: 24) {
            BookCoverThumbnail(coverURL: viewModel.book.bookCoverImageURL, readCount: 1)
            VStack(spacing: 12) {
                Text(viewModel.book.bookTitle)
                    .font(.body1Medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(viewModel.book.bookAuthor)
                    .font(.calloutMedium)
                    .foregroundStyle(secondary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Cards

    private var lightingCard: some View {
        // Figma 897:3811 — 스와치+밝기를 고정 높이 134 블록에 justify-between (스와치 아래 ~43 간격)
        cardContainer(icon: .lightbulb, title: StringLiterals.Reading.lightingTitle, onAdjust: onAdjustLighting) {
            VStack(spacing: 0) {
                Circle()
                    .fill(lightingColor)
                    .frame(width: 74, height: 74)
                Spacer(minLength: 0)
                percentRow(
                    label: StringLiterals.Reading.brightness,
                    percent: viewModel.lightingConfig?.brightness ?? 50,
                    isActive: activeOverlay == .brightness,
                    onTap: { toggle(.brightness) }
                ) {
                    PercentAdjustOverlay(
                        value: brightnessBinding,
                        icon: .lightbulb,
                        iconTint: Color(hex: 0xFFD600),
                        onEnded: { viewModel.commitLighting() }
                    )
                }
            }
            .frame(height: 134)
        }
    }

    private var musicCard: some View {
        // Figma 897:3824 — 아트+카테고리(gap 12) → gap 20 → 볼륨 행 (자연 높이)
        cardContainer(icon: .speaker, title: StringLiterals.Reading.musicTitle, onAdjust: onAdjustMusic) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    musicArt
                    Text(viewModel.musicCategory?.koreanName ?? "-")
                        .font(.labelMedium)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                percentRow(
                    label: StringLiterals.Reading.volume,
                    percent: Int((viewModel.volume * 100).rounded()),
                    isActive: activeOverlay == .volume,
                    onTap: { toggle(.volume) }
                ) {
                    PercentAdjustOverlay(
                        value: volumeBinding,
                        icon: .speaker,
                        iconTint: Color(hex: 0x1C1C1E)
                    )
                }
            }
        }
    }

    private var musicArt: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(musicGradient)
            .frame(width: 74, height: 74)
            .overlay {
                Image(systemName: "play.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
    }

    private var musicGradient: LinearGradient {
        guard let c = viewModel.musicCategory else {
            return LinearGradient(colors: [Color(hex: 0x6E5BB8), Color(hex: 0xCCBFE5)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        let idx = MusicCategory.allCases.firstIndex(of: c) ?? 0
        let hue = Double(idx) / Double(MusicCategory.allCases.count)
        return LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.5, brightness: 0.95),
                Color(hue: (hue + 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.7, brightness: 0.6)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: - Card building blocks

    private func cardContainer<Content: View>(
        icon: SymbolLiterals,
        title: String,
        onAdjust: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 25) {   // Figma gap-25 (헤더 → 콘텐츠)
            HStack(spacing: 6) {
                Image(icon).font(.system(size: 15, weight: .semibold))
                Text(title).font(.calloutMedium)
            }
            .foregroundStyle(.white)

            VStack(spacing: 32) {                     // Figma gap-32 (콘텐츠 블록 → 조정 pill)
                content()
                adjustPill(onAdjust: onAdjust)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 20))
    }

    /// 밝기/볼륨 퍼센트 행. 탭하면 퍼센트 "위에" 세로 슬라이더 오버레이가 뜬다.
    private func percentRow<Overlay: View>(
        label: String,
        percent: Int,
        isActive: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder overlay: () -> Overlay
    ) -> some View {
        HStack {
            Text(label).font(.labelRegular).foregroundStyle(secondary)
            Spacer()
            Text("\(percent)%").font(.labelMedium).foregroundStyle(.white)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .overlay(alignment: .topTrailing) {
            if isActive {
                overlay()
                    .offset(y: -147)   // 오버레이 높이 139 + 여백 8 만큼 퍼센트 위로
            }
        }
    }

    private func adjustPill(onAdjust: @escaping () -> Void) -> some View {
        Button(action: onAdjust) {
            HStack(spacing: 4) {
                Image(.sliderHorizontal).font(.system(size: 11, weight: .semibold))
                Text(StringLiterals.Reading.adjust).font(.labelMedium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(hex: 0x767680, alpha: 0.24), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ overlay: ActiveOverlay) {
        activeOverlay = (activeOverlay == overlay) ? nil : overlay
    }
}

// MARK: - 홈앱 스타일 세로 퍼센트 슬라이더

private struct PercentAdjustOverlay: View {
    @Binding var value: Double   // 0...1
    let icon: SymbolLiterals
    let iconTint: Color
    var onChanged: () -> Void = {}
    var onEnded: () -> Void = {}

    private let w: CGFloat = 48
    private let h: CGFloat = 139

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(.ultraThinMaterial)
            Rectangle()
                .fill(.white)
                .frame(height: max(0, h * value))   // 0%면 채움 없음(빈 상태)
            Image(icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconTint)
                .padding(.bottom, 12)
        }
        .frame(width: w, height: h)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { g in
                    value = min(max(1 - g.location.y / h, 0), 1)
                    onChanged()
                }
                .onEnded { _ in onEnded() }
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("환경 미리보기") {
    EnvironmentPreviewView(
        viewModel: ReadingViewModel(
            previewBook: .mockISBN,
            state: .preview,
            lightingConfig: LightingConfig(hue: 45, saturation: 80, brightness: 50),
            musicCategory: .fairytale
        ),
        onStart: {},
        onAdjustLighting: {},
        onAdjustMusic: {}
    )
    .background(Color.backgroundSecondary)
    .preferredColorScheme(.dark)
}
#endif
