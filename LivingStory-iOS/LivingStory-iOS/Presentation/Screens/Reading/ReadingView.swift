//
//  ReadingView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//

import SwiftUI

struct ReadingView: View {

    let coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("독서 중")

            Spacer()

            // TODO: 타이머, 조명 제어 UI

            Spacer()

            PrimaryButtonSwiftUI(title: "독서 종료") {
                coordinator.pop()
            }
        }
        .padding()
        .navigationTitle("독서 중")
        .keyboardAdaptive()
    }
}
