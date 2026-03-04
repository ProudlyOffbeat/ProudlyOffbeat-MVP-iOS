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
                    coordinator.showStopReading(bookTitle: viewModel.book.bookTitle, conversations: viewModel.conversations)
                }
            }
        } message: {
            if viewModel.state == .reading {
                Text(StringLiterals.Reading.stopReadingAlertMessage)
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
