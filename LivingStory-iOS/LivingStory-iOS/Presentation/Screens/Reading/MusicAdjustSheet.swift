//
//  MusicAdjustSheet.swift
//  LivingStory-iOS
//
//  독서 중 음악 카드 [조정] → "음악 조정" 풀스크린 시트
//  - 상단 무드 축 칩(전체 + 5축)으로 곡 필터
//  - 12개 무드 곡 리스트: 선택 행 하이라이트 + 재생/일시정지 아이콘, Gemini 추천은 ✨ 배지
//  - 하단 미니플레이어: 현재 곡 + 재생/일시정지 + 볼륨
//  - 진입 시 선택곡 일시정지, 다른 곡 탭 시 재생 (ReadingViewModel 실시간 연결)
//

import SwiftUI

struct MusicAdjustSheet: View {

    let viewModel: ReadingViewModel
    @Environment(\.dismiss) private var dismiss

    /// nil = 전체
    @State private var selectedAxis: MoodAxis?

    private var categories: [MusicCategory] {
        guard let axis = selectedAxis else { return MusicCategory.allCases }
        return MusicCategory.allCases.filter { $0.axis == axis }
    }

    private var volumeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.volume) },
            set: { viewModel.setVolume(Float($0)) }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.backgroundSecondary.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            MusicRow(
                                category: category,
                                isSelected: viewModel.musicCategory == category,
                                isPlaying: viewModel.musicCategory == category && viewModel.isMusicPlaying,
                                isRecommended: viewModel.geminiRecommendedMusic == category
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { viewModel.selectMusic(category) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 180) // 미니플레이어 가림 방지
                }
                .safeAreaInset(edge: .top, spacing: 0) { chipBar }

                miniPlayer
            }
            .background(Color.backgroundSecondary)
            .navigationTitle(StringLiterals.Reading.musicAdjustTitle)
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
        .onAppear { viewModel.pauseMusicForAdjust() }
    }

    // MARK: - Chip Bar

    private var chipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                MoodChip(
                    title: StringLiterals.Reading.musicFilterAll,
                    isSelected: selectedAxis == nil
                ) { selectedAxis = nil }

                ForEach(MoodAxis.allCases, id: \.self) { axis in
                    MoodChip(title: axis.koreanLabel, isSelected: selectedAxis == axis) {
                        selectedAxis = axis
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.backgroundSecondary)
    }

    // MARK: - Mini Player

    private var miniPlayer: some View {
        let category = viewModel.musicCategory
        return VStack(spacing: 12) {
            HStack(spacing: 14) {
                MusicThumbnail(category: category, size: 44)
                Text(category?.koreanName ?? "-")
                    .font(.body2Medium)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    viewModel.toggleMusicPlayback()
                } label: {
                    Image(systemName: viewModel.isMusicPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                }
                .disabled(category == nil)
            }

            HStack {
                Text(StringLiterals.Reading.volume)
                    .font(.labelRegular)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(Int((viewModel.volume * 100).rounded()))%")
                    .font(.labelMedium)
                    .foregroundStyle(.white)
            }

            Slider(value: volumeBinding, in: 0...1)
                .tint(LinearGradient(colors: [.yellow20, .green0], startPoint: .leading, endPoint: .trailing))
        }
        .padding(16)
        .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Music Row

private struct MusicRow: View {
    let category: MusicCategory
    let isSelected: Bool
    let isPlaying: Bool
    let isRecommended: Bool

    var body: some View {
        HStack(spacing: 16) {
            MusicThumbnail(
                category: category,
                size: 54,
                playing: isPlaying,
                showsIcon: isSelected,
                badge: isRecommended
            )
            Text(category.koreanName)
                .font(.body2Medium)
                .foregroundStyle(.white)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            isSelected ? Color.white.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - Thumbnail

private struct MusicThumbnail: View {
    let category: MusicCategory?
    let size: CGFloat
    var playing: Bool = false
    var showsIcon: Bool = false
    var badge: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: size >= 50 ? 12 : 10)
            .fill(gradient)
            .frame(width: size, height: size)
            .overlay {
                if showsIcon {
                    Image(systemName: playing ? "pause.fill" : "play.fill")
                        .font(.system(size: size * 0.32, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
            }
            .overlay(alignment: .topTrailing) {
                if badge {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(.black, in: Circle())
                        .offset(x: 4, y: -4)
                }
            }
    }

    /// 곡별 구분용 그라데이션 — 카테고리 인덱스를 색상환에 고르게 분산.
    private var gradient: LinearGradient {
        guard let category else {
            return LinearGradient(
                colors: [Color(hex: 0x3A3A3C), Color(hex: 0x2C2C2E)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        let idx = MusicCategory.allCases.firstIndex(of: category) ?? 0
        let hue = Double(idx) / Double(MusicCategory.allCases.count)
        return LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.5, brightness: 0.95),
                Color(hue: (hue + 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.7, brightness: 0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Mood Chip

private struct MoodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.calloutMedium)
                .foregroundStyle(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.white : Color(hex: 0x2C2C2E),
                    in: Capsule()
                )
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("음악 조정 시트") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            MusicAdjustSheet(
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
