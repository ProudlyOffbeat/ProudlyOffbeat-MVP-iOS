# 🚀 START HERE - 한 달 완성 로드맵

> 이 문서만 따라하면 네카라쿠배급 iOS 포트폴리오 완성!

---

## 📁 현재 프로젝트 구조 (최소 구조)

```
LivingStory-iOS/
├── Application/                  ← 앱 시작점
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Coordinator.swift
│   └── AppCoordinator.swift
│
├── Core/                         ← 공통 유틸리티
│   ├── Preview/                  ← UIKit 라이브 프리뷰
│   │   └── UIViewControllerPreview.swift
│   └── Keyboard/                 ← 키보드 처리
│       └── KeyboardAdaptive.swift
│
├── Presentation/                 ← UI 레이어
│   ├── Screens/                  ← 화면별 폴더
│   │   ├── Home/
│   │   ├── Onboarding/
│   │   ├── Scanner/
│   │   ├── DeviceDiscovery/
│   │   ├── BookProfile/
│   │   ├── Reading/
│   │   └── Statistics/
│   │
│   └── DesignSystem/             ← 디자인 시스템
│       ├── Colors/
│       ├── Fonts/
│       └── Components/
│
├── Resources/                    ← 리소스 파일
│   └── Fonts/
│
├── Base.lproj/
│   └── LaunchScreen.storyboard
│
└── Info.plist
```

---

## 📈 폴더 성장 가이드

> **지금은 최소 구조로 시작합니다. 필요할 때만 폴더를 추가하세요!**

### 🟢 지금 있는 것 (Week 1-2)

| 폴더 | 용도 |
|------|------|
| `Application/` | 앱 시작, Coordinator |
| `Core/Preview/` | UIKit 라이브 프리뷰 |
| `Core/Keyboard/` | 키보드 어댑티브 |
| `Presentation/Screens/` | 화면 (ViewController, View) |
| `Presentation/DesignSystem/` | 색상, 폰트, 버튼 컴포넌트 |
| `Resources/` | 폰트 파일, 이미지 등 |

### 🟡 나중에 추가할 것 (Week 3+)

```
LivingStory-iOS/
├── Application/
├── Presentation/
│
├── 🆕 Data/                      ← Week 3에 추가
│   ├── Repository/               ← 데이터 저장/불러오기
│   │   └── BookRepository.swift
│   ├── Service/                  ← 외부 API 호출
│   │   └── HomeKitService.swift
│   └── Model/                    ← 데이터 모델
│       └── Book.swift
│
├── 🆕 Core/                      ← 필요할 때 추가
│   ├── Extensions/               ← UIView+, String+ 등
│   └── Protocols/                ← 공통 프로토콜
│
└── 🆕 DI/                        ← Week 3에 추가
    └── DIContainer.swift
```

### ❓ 언제 어떤 폴더를 추가하나요?

| 상황 | 추가할 폴더 | 예시 |
|------|------------|------|
| API 호출이 필요할 때 | `Data/Service/` | ISBN으로 책 정보 가져오기 |
| 데이터 저장이 필요할 때 | `Data/Repository/` | 책 목록 UserDefaults 저장 |
| 데이터 모델이 필요할 때 | `Data/Model/` | Book, ReadingSession 구조체 |
| UIView에 기능 추가할 때 | `Core/Extensions/` | `UIView+Shadow.swift` |
| 2개 이상 클래스가 같은 기능 필요할 때 | `Core/Protocols/` | `Loadable` 프로토콜 |
| Service를 ViewController에 주입할 때 | `DI/` | DIContainer |

### 📝 폴더 추가 예시

**예시 1: 책 정보 API 호출이 필요해졌을 때**

```
1. Data/ 폴더 생성
2. Data/Service/ 폴더 생성
3. Data/Service/BookAPIService.swift 생성

// BookAPIService.swift
final class BookAPIService {
    func fetchBook(isbn: String) async throws -> Book {
        // API 호출 로직
    }
}
```

**예시 2: UIView에 그림자 기능을 여러 곳에서 쓸 때**

```
1. Core/ 폴더 생성
2. Core/Extensions/ 폴더 생성
3. Core/Extensions/UIView+Shadow.swift 생성

// UIView+Shadow.swift
extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
    }
}
```

**예시 3: 로딩 상태를 여러 화면에서 공통으로 쓸 때**

```
1. Core/Protocols/ 폴더 생성
2. Core/Protocols/Loadable.swift 생성

// Loadable.swift
protocol Loadable {
    func showLoading()
    func hideLoading()
}

// 사용
class HomeViewController: UIViewController, Loadable {
    func showLoading() { /* 구현 */ }
    func hideLoading() { /* 구현 */ }
}
```

### ⚠️ 주의사항

```
❌ 하지 마세요:
- "나중에 쓸 것 같아서" 미리 폴더 만들기
- 파일 1개인데 폴더 만들기
- 한 곳에서만 쓰는데 Extensions에 넣기

✅ 이렇게 하세요:
- 실제로 필요할 때 폴더 만들기
- 2개 이상 파일이 생길 때 폴더로 정리
- 2곳 이상에서 쓸 때 공통화
```

---

## 👥 역할 분담

| 담당자 | 프레임워크 | 화면 |
|--------|-----------|------|
| 🧑‍💻 **데미안** | UIKit | 온보딩, 홈, 스캐너, 기기 검색 |
| 📱 **이토** | SwiftUI | 책 프로필, 독서 중, 통계 |

---

## 🎯 화면 전환 흐름

```
앱 시작
   │
   ▼
SceneDelegate
   │ appCoordinator = AppCoordinator(...)
   │ appCoordinator.start()
   ▼
AppCoordinator
   │
   ├──▶ showHome()           → HomeViewController (UIKit)
   ├──▶ showOnboarding()     → OnboardingViewController (UIKit)
   ├──▶ showScanner()        → ScannerViewController (UIKit)
   ├──▶ showDeviceDiscovery() → DeviceDiscoveryViewController (UIKit)
   │
   ├──▶ showBookProfile()    → BookProfileView (SwiftUI + UIHostingController)
   ├──▶ showReading()        → ReadingView (SwiftUI + UIHostingController)
   └──▶ showStatistics()     → StatisticsView (SwiftUI + UIHostingController)
```

---

## 📚 UIKit vs SwiftUI 차이점

### UIKit (데미안)

```swift
// 1. ViewController 클래스
final class HomeViewController: UIViewController {

    // 2. Coordinator 참조 (weak으로!)
    weak var coordinator: AppCoordinator?

    // 3. UI 컴포넌트 선언
    private let button = PrimaryButton(title: "스캔")

    // 4. viewDidLoad에서 setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }

    // 5. addSubview
    private func setupUI() {
        view.addSubview(button)
    }

    // 6. AutoLayout (translatesAutoresizingMaskIntoConstraints = false 필수!)
    private func setupLayout() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([...])
    }

    // 7. 버튼 액션
    private func setupActions() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        coordinator?.showScanner()
    }
}
```

### SwiftUI (이토)

```swift
// 1. View 구조체
struct BookProfileView: View {

    // 2. Coordinator 참조 (그냥 let으로)
    let coordinator: AppCoordinator

    // 3. body에서 UI 선언
    var body: some View {
        VStack {
            Text("책 프로필")
                .font(AppTypography.swiftUI.title1)

            PrimaryButtonSwiftUI(title: "독서 시작") {
                coordinator.showReading()
            }
        }
    }
}
```

---

## 🎨 DesignSystem 사용법

### Colors

```swift
// UIKit
view.backgroundColor = AppColors.background
label.textColor = AppColors.textPrimary

// SwiftUI
Text("Hello")
    .foregroundColor(AppColors.swiftUI.textPrimary)
```

### Typography

```swift
// UIKit
label.font = AppTypography.title1

// SwiftUI
Text("Hello")
    .font(AppTypography.swiftUI.title1)
```

### Components

```swift
// UIKit
let button = PrimaryButton(title: "시작하기")
view.addSubview(button)

// SwiftUI
PrimaryButtonSwiftUI(title: "시작하기") {
    // 액션
}
```

---

## 🛠 Core 유틸리티

### UIKit 라이브 프리뷰 (Canvas)

UIKit도 SwiftUI처럼 빌드 없이 프리뷰 확인 가능!

```swift
// ViewController 파일 맨 아래에 추가
#Preview {
    HomeViewController()
}
```

**왜 필요한가?**
- SwiftUI는 Canvas 프리뷰 기본 지원
- UIKit은 원래 안 됨 → `UIViewControllerPreview`로 가능하게!
- 빌드 없이 UI 확인 = 개발 속도 UP

### 키보드 어댑티브

키보드가 올라오면 화면 자동 조정!

```swift
// SwiftUI (간단!)
VStack { ... }
    .keyboardAdaptive()

// UIKit (수동 설정)
class MyViewController: UIViewController {
    private var keyboardHandler: KeyboardHandler?
    private var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardHandler = KeyboardHandler { [weak self] height in
            self?.bottomConstraint.constant = -height
            UIView.animate(withDuration: 0.25) {
                self?.view.layoutIfNeeded()
            }
        }
    }
}
```

**왜 필요한가?**
- TextField 입력 시 키보드가 가림
- 자동으로 화면 올려줌 = UX 향상

---

## 📅 주차별 할 일

### Week 1: UIKit 기초
- [ ] HomeViewController UI 완성
- [ ] OnboardingViewController UI 완성 (3페이지 슬라이드)
- [ ] AutoLayout 코드 기반 연습
- [ ] DesignSystem 활용

### Week 2: 화면 확장
- [ ] ScannerViewController 카메라 프리뷰
- [ ] DeviceDiscoveryViewController 기기 목록
- [ ] 화면 간 데이터 전달

### Week 3: DIContainer 도입
- [ ] DIContainer.swift 생성
- [ ] Repository, Service 추가
- [ ] Protocol 기반 설계

### Week 4: SwiftUI 연동 (이토)
- [ ] BookProfileView UI 완성
- [ ] ReadingView UI 완성
- [ ] StatisticsView UI 완성
- [ ] UIKit ↔ SwiftUI 데이터 전달

---

## ❓ FAQ

### Q: AnyObject를 왜 쓰나요?

`Coordinator.swift` 파일 상단 주석에 자세히 설명되어 있습니다.

```swift
// AnyObject = "이 프로토콜은 클래스만 채택할 수 있다"
// weak var coordinator: AppCoordinator? 를 쓰려면 클래스여야 함
// struct는 값 타입이라 weak 불가능
```

### Q: DIContainer는 언제 추가하나요?

```
Week 1-2: 필요 없음 (화면만 있음)
Week 3+: 추가 (Repository, Service 생기면)
```

### Q: Factory 패턴은 언제 추가하나요?

```
Week 1-2: 필요 없음
Week 3+: ViewModel 도입하면 ViewControllerFactory 고려

// Before (지금)
let vc = HomeViewController()

// After (Week 3+)
let vc = factory.makeHomeVC()  // Factory가 ViewModel 주입
```

### Q: Router는 왜 분리하나요?

```
지금: AppCoordinator가 직접 push/pop
나중: Router로 분리하면 테스트 쉬움

→ 테스트 코드 작성할 때 고려 (선택사항)
→ 자세한 내용은 learning/10-Coordinator-Advanced.md 참고
```

### Q: SwiftUI에서 Coordinator를 어떻게 호출하나요?

```swift
struct BookProfileView: View {
    let coordinator: AppCoordinator  // 생성자로 전달받음

    var body: some View {
        Button("뒤로") {
            coordinator.pop()
        }
    }
}
```

---

## 📚 참고 문서

| 문서 | 내용 |
|------|------|
| `IMPLEMENTATION_COOKBOOK.md` | 파일 위치 + DI 흐름도 |
| `FEATURE_SPEC.md` | 기능 명세서 |
| `TECH_ROADMAP.md` | 기술 도입 타이밍 |
| `learning/09-AutoLayout-SnapKit.md` | AutoLayout 가이드 |
| `learning/05-Coordinator-Pattern.md` | Coordinator 상세 |

---

## 🎯 최종 목표

```
한 달 후:
✅ UIKit + AutoLayout 능숙
✅ SwiftUI 기초 이해
✅ Coordinator 패턴 마스터
✅ DI 패턴 이해
✅ UIKit ↔ SwiftUI 연동 가능
✅ 네카라쿠배급 면접 준비 완료!
```

---

**이제 HomeViewController.swift 열고 UI 만들기 시작하세요!** 🚀
