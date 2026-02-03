//
//  HomeViewController.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  🧑‍💻 담당: 데미안 (UIKit)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  📚 UIKit ViewController 작성법
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  1️⃣ UI 컴포넌트 선언 (private let)
//     ```swift
//     private let titleLabel: UILabel = {
//         let label = UILabel()
//         label.text = "홈"
//         label.font = AppTypography.title1
//         return label
//     }()
//     ```
//
//  2️⃣ viewDidLoad에서 setup 메서드 호출
//
//  3️⃣ setupUI: addSubview + 기본 설정
//
//  4️⃣ setupLayout: AutoLayout
//     - translatesAutoresizingMaskIntoConstraints = false 필수!
//
//  5️⃣ setupActions: 버튼 액션 연결
//     - addTarget + @objc 메서드
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    // MARK: - UI Components
    // TODO: 여기에 UI 컴포넌트 추가

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(named: "gray100")
        title = StringLiterals.Home.title
    }

    private func setupLayout() {
        // TODO: AutoLayout 코드
    }

    private func setupActions() {
        // TODO: 버튼 액션 연결
    }
}

// MARK: - Preview

#Preview {
    HomeViewController()
}
