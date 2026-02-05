# 🚀 LivingStory-iOS 마스터 플랜

> **목표**: 네카라쿠배급 취업을 위한 포트폴리오 프로젝트
> **전략**: 점진적 리팩토링 (MVC → MVVM, UIKit → SwiftUI, RxSwift → Combine)

---

## 📋 프로젝트 개요

| 항목 | 내용 |
|-----|------|
| **앱 이름** | LivingStory (리빙스토리) |
| **핵심 기능** | 동화책 읽기 + HomeKit 조명/스피커 연동 |
| **타겟** | iOS 26+ / Swift 6 |
| **담당 분리** | 데미안(UIKit 앞단) / 이토(SwiftUI 뒷단) |

---

## 🎯 리팩토링 로드맵

```
Phase 1 (현재)     Phase 2           Phase 3           Phase 4           Phase 5
─────────────────────────────────────────────────────────────────────────────────
UIKit + MVC    →   SwiftUI 통합   →   MVVM + RxSwift  →   Combine 전환   →   iOS 26 완성
Observable<T>      UIHostingVC        Input/Output       @Published        Liquid Glass
BaseVC             Coordinator         ViewModel          SwiftUI 6
```

---

## 📅 4주 스프린트 플랜

### Week 1: 프로젝트 기반 구축 (✅ 완료)

| Day | 태스크 | 결과물 | 상태 |
|-----|-------|--------|------|
| D1 | 폴더 구조 생성 | Domain/Data/Infrastructure/Presentation | ✅ |
| D2 | Base 클래스 작성 | BaseViewController, Coordinator | ✅ |
| D3 | Domain 엔티티 정의 | Book, Device, Room, ColorPreset | ✅ |
| D4 | Repository Protocol | BookRepository, DeviceRepository | ✅ |
| D5 | Observable 패턴 | @MainActor Observable<T> | ✅ |
| D6 | UIKit+SwiftUI 연동 | UIHostingController, Bridge | ✅ |
| D7 | 문서화 | 학습 자료 MD 파일 | ✅ |

### Week 2: 온보딩 + HomeKit

| Day | 태스크 | 결과물 | 학습 자료 |
|-----|-------|--------|----------|
| D1 | HomeKit 권한 요청 | PermissionService | `02-HomeKit-Integration.md` |
| D2 | HMHomeManager 래핑 | HomeKitService (Actor) | `01-Swift6-Concurrency.md` |
| D3 | 기기 검색 UI | DeviceDiscoveryVC | UIKit 실습 |
| D4 | 기기 등록 로직 | DeviceRepository 구현 | CoreData 연동 |
| D5 | 방 생성/관리 | RoomViewController | TableView/CollectionView |
| D6 | 온보딩 플로우 완성 | OnboardingCoordinator | `05-Coordinator-Pattern.md` |
| D7 | 테스트 & 리뷰 | XCTest 작성 | - |

### Week 3: 바코드 스캔 + ISBN API

| Day | 태스크 | 결과물 | 학습 자료 |
|-----|-------|--------|----------|
| D1 | AVFoundation 세팅 | CameraService | `03-AVFoundation-Barcode.md` |
| D2 | 바코드 인식 | ScannerService | - |
| D3 | ISBN API 연동 | BookAPIService | `06-ISBN-API-Guide.md` |
| D4 | 책 정보 파싱 | BookRepository 완성 | DTO → Entity 매핑 |
| D5 | 스캔 UI 완성 | ScannerViewController | UIKit 실습 |
| D6 | 카테고리 분류 | CategoryPresetService | AI API 연동 검토 |
| D7 | 테스트 & 리뷰 | Unit Test 작성 | - |

### Week 4: 통합 + CI/CD

| Day | 태스크 | 결과물 | 학습 자료 |
|-----|-------|--------|----------|
| D1 | 화면 전환 통합 | Coordinator 완성 | `04-UIKit-SwiftUI-Interop.md` |
| D2 | SwiftUI 화면 연동 | BookProfile, Statistics | 이토와 협업 |
| D3 | Unit Test | ISBN Parser, Repository | XCTest |
| D4 | GitHub Actions CI | PR 빌드 자동화 | `08-GitHub-Actions-CI.md` |
| D5 | fastlane 배포 | TestFlight 업로드 | - |
| D6 | 문서화 | README, 아키텍처 다이어그램 | - |
| D7 | 코드 리뷰 & 정리 | - | - |

---

## 🔄 리팩토링 스프린트 (Week 5-8)

### Week 5-6: MVVM + RxSwift

| 태스크 | 설명 |
|-------|------|
| ViewModel 분리 | 각 VC에서 상태/로직 분리 |
| RxSwift 도입 | Observable → BehaviorRelay |
| Input/Output 패턴 | transform() 메서드 |
| 테스트 강화 | ViewModel Unit Test |

### Week 7-8: Combine + SwiftUI

| 태스크 | 설명 |
|-------|------|
| RxSwift → Combine | @Published, AnyPublisher |
| ObservableObject | ViewModel SwiftUI 호환 |
| SwiftUI 마이그레이션 | 일부 UIKit 화면 전환 |
| iOS 26 기능 | Liquid Glass, SwiftUI 6 |

---

## 📁 폴더 구조

```
LivingStory-iOS/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── AppCoordinator.swift
│   └── DIContainer.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── Book.swift
│   │   ├── Device.swift
│   │   ├── Room.swift
│   │   ├── ColorPreset.swift
│   │   └── ReadingSession.swift
│   ├── UseCases/
│   │   └── UseCases.swift
│   └── Protocols/
│       └── RepositoryProtocols.swift
│
├── Data/
│   ├── Repositories/
│   ├── DataSources/
│   │   ├── Local/
│   │   └── Remote/
│   ├── DTOs/
│   └── Mappers/
│
├── Infrastructure/
│   ├── HomeKit/
│   ├── Network/
│   ├── Scanner/
│   └── Storage/
│
├── Presentation/
│   ├── Common/
│   │   ├── Base/
│   │   │   └── BaseViewController.swift
│   │   ├── Components/
│   │   └── UIKitSwiftUIBridge.swift
│   ├── Coordinators/
│   │   └── Coordinator.swift
│   └── Scenes/
│       ├── Onboarding/          (UIKit - 데미안)
│       ├── Home/                 (UIKit - 데미안)
│       ├── Scanner/              (UIKit - 데미안)
│       ├── BookProfile/          (SwiftUI - 이토)
│       ├── Reading/              (SwiftUI - 이토)
│       └── Statistics/           (SwiftUI - 이토)
│
└── Core/
    ├── Extensions/
    ├── Constants/
    ├── Protocols/
    │   └── Observable.swift
    └── Resources/
```

---

## 🛠 기술 스택 체크리스트

### 필수 (✅ Must Have)

| 카테고리 | 기술 | 상태 |
|---------|------|------|
| UI | UIKit + AutoLayout | ✅ 준비됨 |
| UI | SwiftUI (통합) | ✅ 준비됨 |
| 아키텍처 | MVC → MVVM | 🔄 진행 예정 |
| 아키텍처 | Coordinator | ✅ 준비됨 |
| 비동기 | Swift Concurrency | ✅ 준비됨 |
| 데이터 | CoreData | 🔄 구현 예정 |
| 보안 | Keychain | 🔄 구현 예정 |
| 테스트 | XCTest | 🔄 구현 예정 |
| CI/CD | GitHub Actions | 🔄 구현 예정 |
| CI/CD | fastlane | 🔄 구현 예정 |

### 권장 (⭕ Should Have)

| 카테고리 | 기술 | 상태 |
|---------|------|------|
| UI | FlexLayout/PinLayout | ⏳ 검토 중 |
| 네트워크 | Alamofire | ⏳ 검토 중 |
| 분석 | Firebase Crashlytics | 🔄 구현 예정 |
| 분석 | Firebase Analytics | 🔄 구현 예정 |

### 추가 (➕ Nice to Have)

| 카테고리 | 기술 | 상태 |
|---------|------|------|
| 아키텍처 | RIBs (일부 모듈) | ⏳ 리팩토링 시 |
| 반응형 | RxSwift → Combine | ⏳ Phase 3-4 |
| CI/CD | Xcode Cloud | ⏳ 검토 중 |

---

## 📚 학습 자료 목록

| # | 파일명 | 내용 | WWDC |
|---|--------|------|------|
| 01 | `Swift6-Concurrency.md` | async/await, Actor, @MainActor | WWDC21-24 |
| 02 | `HomeKit-Integration.md` | HMHomeManager, 특성값 제어 | WWDC21-22 |
| 03 | `AVFoundation-Barcode.md` | ISBN 바코드 스캔 | WWDC19 |
| 04 | `UIKit-SwiftUI-Interop.md` | UIHostingController, UIViewRepresentable | WWDC22-23 |
| 05 | `Coordinator-Pattern.md` | 화면 전환 추상화, Deep Link | - |
| 06 | `ISBN-API-Guide.md` | 국립중앙도서관, 알라딘 API | - |
| 07 | `MVC-to-MVVM-Migration.md` | 점진적 아키텍처 전환 | - |
| 08 | `GitHub-Actions-CI.md` | CI/CD 파이프라인 구축 | - |

---

## 🎨 화면 담당 분리

### 데미안 (UIKit)

| 화면 | 설명 | 우선순위 |
|-----|------|---------|
| Onboarding | 온보딩 페이지, 기기 검색 | Week 2 |
| Home | 방/기기 목록, 메인 화면 | Week 2-3 |
| Scanner | 바코드 스캔 카메라 | Week 3 |

### 이토 (SwiftUI)

| 화면 | 설명 | 우선순위 |
|-----|------|---------|
| BookProfile | 책 정보, 프리셋 선택 | Week 3-4 |
| Reading | 독서 진행, 타이머 | Week 4 |
| Statistics | 캘린더, 통계 | Week 4 |

---

## 🔗 연동 포인트

### UIKit → SwiftUI 전환 지점

```swift
// HomeCoordinator.swift
func showBookProfile(book: Book) {
    let view = BookProfileView(book: book) { book in
        self.showReading(book: book)  // 콜백으로 다시 UIKit Coordinator로
    }
    pushSwiftUI(view)
}
```

### 데이터 공유

```swift
// Observable<T> (MVC) → ObservableWrapper → SwiftUI @StateObject
// 추후: @Published (MVVM + Combine) → SwiftUI 직접 바인딩
```

---

## ✅ 일일 체크리스트 템플릿

```markdown
## 📅 Day X (날짜)

### 오늘 목표
- [ ] 태스크 1
- [ ] 태스크 2
- [ ] 태스크 3

### 완료
- [x] 완료된 태스크

### 배운 것
- 학습 내용 기록

### 이슈
- 발생한 문제와 해결 방법

### 내일 계획
- 다음 날 할 일
```

---

## 📈 포트폴리오 어필 포인트

1. **점진적 리팩토링 경험**
   - MVC → MVVM 전환 과정 문서화
   - RxSwift → Combine 마이그레이션

2. **UIKit + SwiftUI 하이브리드**
   - Coordinator 패턴으로 통합 관리
   - 실무에서 자주 만나는 상황

3. **HomeKit 연동**
   - IoT/스마트홈 도메인 경험
   - Apple 생태계 깊은 이해

4. **Swift 6 + iOS 26**
   - 최신 기술 스택 활용
   - Strict Concurrency 대응

5. **CI/CD 자동화**
   - GitHub Actions + fastlane
   - 실무 수준의 배포 파이프라인

---

**시작일**: 2026년 1월 30일
**목표 완료일**: 2026년 2월 28일 (4주)
**리팩토링 완료일**: 2026년 3월 31일 (추가 4주)
