//
//  OnboardingFlowView.swift
//  LivingStory-iOS
//
//  온보딩 세팅 플로우 루트. phase(OnboardingPhase) 하나로 화면 분기.
//

import SwiftUI

struct OnboardingFlowView: View {

    // 코디네이터가 생성·주입 (생성/완료 와이어링은 코디네이터 책임)
    @State var viewModel: OnboardingFlowViewModel

    var body: some View {
        Group {
            switch viewModel.phase {
            case .requestingPermission:
                // 권한 다이얼로그 대기 — 검정 유지
                Color(uiColor: .systemBackground).ignoresSafeArea()

            case .permissionDenied:
                PermissionDeniedView(onOpenSettings: { viewModel.openSystemSettings() })

            case .setup(let step):
                SetupScaffold(
                    step: step,
                    progress: viewModel.progress,
                    showsBack: step != viewModel.activeSteps.first,   // 첫 단계엔 뒤로 없음
                    isCTAEnabled: isCTAEnabled(for: step),
                    onBack: { viewModel.back() },
                    onCTA: { viewModel.next() },
                    onSkip: step.isSkippable ? { viewModel.skip() } : nil
                ) {
                    stepContent(step)
                }

            case .completed:
                SetupCompleteView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.phase)
        .sensoryFeedback(.impact, trigger: viewModel.phase)          // 다음/완료/뒤로 단계 전환
        .sensoryFeedback(.selection, trigger: viewModel.childAge)    // 나이 슬라이더
        .sensoryFeedback(.selection, trigger: viewModel.readingTime) // 시간 피커
    }

    // MARK: - Step Content

    @ViewBuilder
    private func stepContent(_ step: SetupStep) -> some View {
        switch step {
        case .home:
            HomeSelectView(
                homes: viewModel.homes,
                selectedID: Binding(
                    get: { viewModel.selectedHomeID },
                    set: { if let id = $0 { viewModel.selectHome(id) } }
                )
            )
        case .light:
            DeviceToggleListView(
                rooms: viewModel.lightRooms(),
                enabledIDs: viewModel.enabledLightIDs,
                onToggle: { viewModel.toggleLight($0) }
            )
        case .speaker:
            DeviceToggleListView(
                rooms: viewModel.speakerRooms(),
                enabledIDs: viewModel.enabledSpeakerIDs,
                onToggle: { viewModel.toggleSpeaker($0) }
            )
        case .age:
            AgeSelectView(age: Binding(
                get: { viewModel.childAge },
                set: { viewModel.childAge = $0 }
            ))
        case .time:
            TimeSelectView(time: Binding(
                get: { viewModel.readingTime },
                set: { viewModel.readingTime = $0 }
            ))
        }
    }

    private func isCTAEnabled(for step: SetupStep) -> Bool {
        switch step {
        case .home: viewModel.selectedHomeID != nil
        default:    true
        }
    }
}
