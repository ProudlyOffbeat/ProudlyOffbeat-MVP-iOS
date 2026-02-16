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
            viewModel.state == .setting ? StringLiterals.Reading.stopSettingAlert : StringLiterals.Reading.stopReadingAlert,
            isPresented: $showStopAlert
        ) {
            Button(StringLiterals.Reading.close, role: .cancel) {}
            Button(StringLiterals.Reading.stop, role: .destructive) {
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
