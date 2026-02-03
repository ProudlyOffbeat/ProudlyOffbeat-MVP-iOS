//
//  StatisticsView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//

import SwiftUI

struct StatisticsView: View {

    let coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("통계")
                .font(.largeTitleEmphasized)

            Spacer()

            // TODO: 차트, 독서 기록 UI

            Spacer()
        }
        .padding()
        .navigationTitle("통계")
    }
}
