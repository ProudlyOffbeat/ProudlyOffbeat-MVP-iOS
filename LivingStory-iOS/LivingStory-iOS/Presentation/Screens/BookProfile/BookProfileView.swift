//
//  BookProfileView.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📱 담당: 이토 (SwiftUI)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  📚 SwiftUI View 작성법
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  1️⃣ View 구조체 + Coordinator
//     ```swift
//     struct MyView: View {
//         let coordinator: AppCoordinator
//     }
//     ```
//
//  2️⃣ 상태 관리
//     - @State: View 내부 상태
//     - @Binding: 부모에서 받은 상태
//     - @StateObject: ViewModel (MVVM)
//
//  3️⃣ 키보드 어댑티브
//     ```swift
//     VStack { ... }
//         .keyboardAdaptive()
//     ```
//
//  4️⃣ 화면 전환
//     - coordinator.showReading()
//     - coordinator.pop()
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct BookProfileView: View {

    // MARK: - Properties

    let coordinator: AppCoordinator

    // MARK: - Body

    var body: some View {
        VStack {
            Text("책 프로필")
                .font(.largeTitleEmphasized)

            Spacer()

            // TODO: 책 정보 UI

            Spacer()

            PrimaryButtonSwiftUI(title: "독서 시작") {
                coordinator.showReading()
            }
        }
        .padding()
        .navigationTitle("책 프로필")
        .keyboardAdaptive()
    }
}
