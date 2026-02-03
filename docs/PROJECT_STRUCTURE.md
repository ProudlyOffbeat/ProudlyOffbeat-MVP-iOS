# 📋 LivingStory-iOS 프로젝트 구조 (원페이저)

> 마지막 업데이트: 2026-02-03

---

## 📁 전체 폴더 구조

```
LivingStory-iOS/
│
├── 📱 Application/                     ← 앱 시작점 + 네비게이션
│   ├── AppDelegate.swift               → 앱 생명주기
│   ├── SceneDelegate.swift             → 화면 생명주기, Coordinator 시작
│   ├── Coordinator.swift               → Coordinator 프로토콜 (AnyObject)
│   └── AppCoordinator.swift            → 모든 화면 전환 담당
│
├── 🛠 Core/                             ← 공통 유틸리티
│   ├── Preview/
│   │   └── UIViewControllerPreview.swift → UIKit 라이브 프리뷰
│   └── Keyboard/
│       └── KeyboardAdaptive.swift      → 키보드 어댑티브 (UIKit + SwiftUI)
│
├── 🎨 Presentation/                    ← UI 레이어
│   │
│   ├── Screens/                        ← 화면별 폴더
│   │   │
│   │   ├── 🧑‍💻 [데미안 담당 - UIKit]
│   │   │   ├── Home/
│   │   │   │   └── HomeViewController.swift
│   │   │   ├── Onboarding/
│   │   │   │   └── OnboardingViewController.swift
│   │   │   ├── Scanner/
│   │   │   │   └── ScannerViewController.swift
│   │   │   └── DeviceDiscovery/
│   │   │       └── DeviceDiscoveryViewController.swift
│   │   │
│   │   └── 📱 [이토 담당 - SwiftUI]
│   │       ├── BookProfile/
│   │       │   └── BookProfileView.swift
│   │       ├── Reading/
│   │       │   └── ReadingView.swift
│   │       └── Statistics/
│   │           └── StatisticsView.swift
│   │
│   └── DesignSystem/                   ← 디자인 시스템
│       ├── Colors/
│       │   └── AppColors.swift         → 색상 (UIKit + SwiftUI)
│       ├── Fonts/
│       │   └── AppTypography.swift     → 타이포그래피 (UIKit + SwiftUI)
│       └── Components/
│           └── PrimaryButton.swift     → 버튼 (UIKit + SwiftUI)
│
├── 📦 Resources/                       ← 리소스 파일
│   └── Fonts/                          → 커스텀 폰트 (.ttf, .otf)
│
├── 🚀 Base.lproj/
│   └── LaunchScreen.storyboard         → 런치 스크린
│
└── Info.plist                          → 앱 설정
```

---

## 📄 파일별 역할

### Application (앱 시작)

| 파일 | 역할 | 핵심 코드 |
|------|------|-----------|
| `AppDelegate.swift` | 앱 생명주기 | `application(_:didFinishLaunching...)` |
| `SceneDelegate.swift` | Coordinator 시작점 | `appCoordinator?.start()` |
| `Coordinator.swift` | 프로토콜 정의 | `protocol Coordinator: AnyObject` |
| `AppCoordinator.swift` | 화면 전환 | `showHome()`, `showScanner()`, `pop()` |

### Core (공통 유틸리티)

| 파일 | 역할 | 사용법 |
|------|------|--------|
| `UIViewControllerPreview.swift` | UIKit 프리뷰 | `#Preview { HomeViewController() }` |
| `KeyboardAdaptive.swift` | 키보드 처리 | `.keyboardAdaptive()` (SwiftUI) |

### Presentation/Screens (화면)

| 화면 | 담당 | 프레임워크 | 파일 |
|------|------|-----------|------|
| 홈 | 데미안 | UIKit | `HomeViewController.swift` |
| 온보딩 | 데미안 | UIKit | `OnboardingViewController.swift` |
| 스캐너 | 데미안 | UIKit | `ScannerViewController.swift` |
| 기기 검색 | 데미안 | UIKit | `DeviceDiscoveryViewController.swift` |
| 책 프로필 | 이토 | SwiftUI | `BookProfileView.swift` |
| 독서 중 | 이토 | SwiftUI | `ReadingView.swift` |
| 통계 | 이토 | SwiftUI | `StatisticsView.swift` |

### Presentation/DesignSystem (디자인)

| 파일 | 역할 | UIKit | SwiftUI |
|------|------|-------|---------|
| `AppColors.swift` | 색상 | `AppColors.background` | `AppColors.swiftUI.background` |
| `AppTypography.swift` | 폰트 | `AppTypography.title1` | `AppTypography.swiftUI.title1` |
| `PrimaryButton.swift` | 버튼 | `PrimaryButton(title:)` | `PrimaryButtonSwiftUI(title:action:)` |

---

## 🔄 화면 전환 흐름

```
앱 시작
   │
   ▼
SceneDelegate.swift
   │ let navigationController = UINavigationController()
   │ appCoordinator = AppCoordinator(navigationController:)
   │ appCoordinator.start()
   │
   ▼
AppCoordinator.swift
   │
   ├─▶ showHome()            → HomeViewController
   ├─▶ showOnboarding()      → OnboardingViewController
   ├─▶ showScanner()         → ScannerViewController
   ├─▶ showDeviceDiscovery() → DeviceDiscoveryViewController
   │
   ├─▶ showBookProfile()     → BookProfileView (UIHostingController)
   ├─▶ showReading()         → ReadingView (UIHostingController)
   ├─▶ showStatistics()      → StatisticsView (UIHostingController)
   │
   └─▶ pop()                 → 뒤로가기
```

---

## 📈 폴더 성장 계획

### 현재 (Week 1-2)
```
✅ Application/
✅ Core/Preview/, Core/Keyboard/
✅ Presentation/Screens/
✅ Presentation/DesignSystem/
✅ Resources/
```

### Week 3+ (필요시 추가)
```
🆕 Data/
   ├── Repository/    → BookRepository.swift (데이터 저장)
   ├── Service/       → HomeKitService.swift (API 호출)
   └── Model/         → Book.swift (데이터 모델)

🆕 Core/Extensions/   → UIView+Shadow.swift (확장)
🆕 Core/Protocols/    → Loadable.swift (공통 프로토콜)
🆕 DI/                → DIContainer.swift (의존성 주입)
```

---

## ✅ 설정 완료 체크리스트

### 기본 설정
- [x] Coordinator 패턴 적용
- [x] UIKit + SwiftUI 혼용 구조
- [x] DesignSystem (Colors, Fonts, Components)
- [x] LaunchScreen 설정

### Core 유틸리티
- [x] UIKit 라이브 프리뷰 (`#Preview`)
- [x] 키보드 어댑티브 (`.keyboardAdaptive()`)
- [x] UIFont → Font 변환 (`Font(uiFont)`)

### Info.plist
- [x] HomeKit 권한 설명
- [x] 카메라 권한 설명
- [x] Scene Configuration

---

## 📚 문서 공유 가이드

### 팀원에게 공유 (필수)

| 문서 | 내용 | 대상 |
|------|------|------|
| `00_START_HERE.md` | 시작 가이드 + 사용법 | 전체 팀 |
| `PROJECT_STRUCTURE.md` | 프로젝트 구조 (이 문서) | 전체 팀 |
| `learning/*.md` | 학습 자료 | 필요한 팀원 |

### 개인 학습용 (선택)

| 문서 | 내용 | 언제 볼까? |
|------|------|-----------|
| `IMPLEMENTATION_COOKBOOK.md` | DI 흐름도 | Week 3+ |
| `FEATURE_SPEC.md` | 기능 명세서 | 기획 확인 시 |
| `TECH_ROADMAP.md` | 기술 로드맵 | 장기 계획 시 |
| `learning/10-Coordinator-Advanced.md` | Router, Factory 심화 | Week 3+ |

---

## 👥 역할 분담

```
┌─────────────────────────────────────────────────────────────┐
│                    LivingStory-iOS                          │
├─────────────────────────────┬───────────────────────────────┤
│     🧑‍💻 데미안 (UIKit)        │     📱 이토 (SwiftUI)          │
├─────────────────────────────┼───────────────────────────────┤
│  • HomeViewController       │  • BookProfileView            │
│  • OnboardingViewController │  • ReadingView                │
│  • ScannerViewController    │  • StatisticsView             │
│  • DeviceDiscoveryVC        │                               │
├─────────────────────────────┴───────────────────────────────┤
│                    공통 (DesignSystem)                       │
│  • AppColors • AppTypography • PrimaryButton                │
└─────────────────────────────────────────────────────────────┘
```

---

**이 문서는 프로젝트 구조가 변경될 때마다 업데이트하세요!**
