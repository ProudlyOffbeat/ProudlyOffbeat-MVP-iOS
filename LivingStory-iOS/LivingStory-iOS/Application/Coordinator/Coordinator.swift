//
//  Coordinator.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 AnyObject를 왜 쓰나요?
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  AnyObject = "이 프로토콜은 클래스만 채택할 수 있다"
//
//  왜 필요한가?
//  - ViewController에서 coordinator를 weak으로 참조해야 함
//  - weak은 클래스(참조 타입)에만 사용 가능
//  - struct는 값 타입이라 weak 불가능
//
//  예시:
//  ```swift
//  class HomeViewController {
//      weak var coordinator: AppCoordinator?  // ✅ 가능 (클래스니까)
//  }
//
//  struct SomeStruct: Coordinator { }  // ❌ 컴파일 에러 (AnyObject 때문에)
//  ```
//
//  순환 참조 방지:
//  - Coordinator → ViewController 강한 참조 (push할 때)
//  - ViewController → Coordinator weak 참조 (순환 방지)
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}
