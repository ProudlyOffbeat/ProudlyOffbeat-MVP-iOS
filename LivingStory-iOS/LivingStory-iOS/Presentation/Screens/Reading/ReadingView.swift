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

    var body: some View {
        VStack {
            Spacer()
            statusContent
            Spacer()
            actionButton
                .padding(.horizontal, 20)
        }
        .navigationTitle(viewModel.book.bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background { pulseBackground }
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
            viewModel.state == .setting ? "환경 세팅을 전체 중단할까요?" : "독서를 중단할까요?",
            isPresented: $showStopAlert
        ) {
            Button("닫기", role: .cancel) {}
            Button("중단", role: .destructive) {
                viewModel.stopReading()
                if viewModel.state == .setting {
                    coordinator.pop()
                } else {
                    coordinator.showStopReading()
                }
            }
        }
        .task {
            //await viewModel.startSetup()
        }
    }

    // MARK: - Subviews

    private var statusContent: some View {
        VStack(spacing: 28) {
            Image(systemName: viewModel.state == .setting ? "house.fill" : "music.note.house.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(height: 79)
                .id(viewModel.state)

            VStack(spacing: 6) {
                Text(viewModel.state == .setting ? "환경 세팅중..." : "책 분위기에 맞게 환경이 세팅 됐어요!")
                    .font(.bodyRegular)
                    .foregroundStyle(.white)
                Text(viewModel.state == .setting ? "몇 분 소요될 수 있습니다." : "책 흐름에 맞게 분위기가 변할거에요.\n이제 책을 더 재밌게 읽으세요!")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .opacity(0.5)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var actionButton: some View {
        PrimaryButtonSwiftUI(
            title: viewModel.state == .setting ? "환경 세팅 중지" : "독서 중지"
        ) {
            showStopAlert = true
        }
        .environment(\.colorScheme, .dark)
    }

    private var pulseBackground: some View {
        ZStack {
            Color.black
            if viewModel.state == .setting {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow0, .yellow20, .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 305
                        )
                    )
                    .frame(width: 610, height: 610)
                    .scaleEffect(isPulsing ? 1.0 : 0.85)
                    .opacity(isPulsing ? 0.3 : 0.05)
                    .blur(radius: 50)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ReadingView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            viewModel: ReadingViewModel(book: .mock)
        )
    }
}
