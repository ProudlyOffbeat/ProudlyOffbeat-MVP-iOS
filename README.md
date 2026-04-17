# 📖 나루 (LivingStory) — HomeKit 연동 몰입형 동화 읽기 앱

<div align="center">
   <img width="600" alt="나루 앱 대표 이미지" src="https://github.com/user-attachments/assets/bee9e1aa-23a2-438b-b54a-21b8ab7bed32" />
</div>

![Xcode](https://img.shields.io/badge/Xcode-16.4-blue?logo=xcode&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-26+-lightgrey?logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-6.0.2-orange?logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-000000?style=flat&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0D1117?style=flat&logo=swift&logoColor=white)

> **"읽는 것을 넘어, 공간이 이야기가 되는 경험"**
> 바코드 한 번으로 책을 등록하고, HomeKit 조명·사운드가 동화와 함께 움직입니다.

---

## 🧩 About

**나루(LivingStory)**는 아이들이 동화책을 읽으며 실제 공간의 조명과 사운드가 이야기에 맞춰 변하는 **몰입형 동화 읽기 앱**입니다.

ISBN 바코드를 스캔해 책을 등록하고, HomeKit 연동 스마트 기기가 동화 장면에 따라 빛과 소리를 연출합니다. 읽기 세션을 기록하고 통계를 확인할 수 있어 읽기 습관 형성까지 지원합니다.

---

## 🏘️ Team

<div align="center">

| <a href="https://github.com/YooGyeongMo"><img src="https://github.com/YooGyeongMo.png" width="80"/><br/><b>Demian</b><br/>UIKit 앞단</a> | <a href="https://github.com/changjaemun"><img src="https://github.com/changjaemun.png" width="80"/><br/><b>Ito</b><br/>SwiftUI 뒷단</a> |
|:--:|:--:|

</div>

| 담당자 | 역할 | 담당 화면 |
|---|---|---|
| **Demian (데미안)** | UIKit 기반 화면 · Coordinator · 네트워크 | 온보딩 · 홈 · 스캐너 |
| **Ito (이토)** | SwiftUI 기반 화면 · 데이터 계층 | 책 프로필 · 책 읽기 · 통계 |

---

## 📌 Main Features

### 📷 바코드 스캔 & ISBN 등록
- AVFoundation 기반 ISBN 바코드 스캐너
- Kakao Book API로 도서 정보 자동 조회 (제목 · 저자 · 표지)
- CoreData에 책 영구 저장 (BookRepository)

### 📚 홈 & 서재
- 등록된 동화책 캐러셀 UI (UICollectionView + Custom FlowLayout)
- 책별 프로필 상세 화면

### 📖 읽기 세션 & 타이머
- 동화 읽기 시작/종료 기록
- 읽기 세션별 시간 측정 (ReadingSessionRepository)
- Gemini AI 기반 독후감 대화 지원

### 🏡 HomeKit 공간 연출
- HMHomeManager 기반 스마트 기기 검색 · 등록
- 조명 색상 · 밝기 · 사운드를 동화 장면에 맞춰 제어
- 배경 음악 재생 (AVFoundation AudioPlayerService)

### 📊 읽기 통계
- 총 읽기 시간 · 완독 권수 · 캘린더 기반 읽기 기록
- StatCardView로 시각화

---

## 🛠️ Tech Stack

### Frameworks

<div align="left">
<img src="https://img.shields.io/badge/Swift_6-FA7343?style=flat&logo=Swift&logoColor=white"/>
<img src="https://img.shields.io/badge/UIKit-000000?style=flat&logo=apple&logoColor=white"/>
<img src="https://img.shields.io/badge/SwiftUI-0D1117?style=flat&logo=swift&logoColor=white"/>
<img src="https://img.shields.io/badge/CoreData-4285F4?style=flat&logo=apple&logoColor=white"/>
<img src="https://img.shields.io/badge/HomeKit-F9AB00?style=flat&logo=apple&logoColor=white"/>
<img src="https://img.shields.io/badge/AVFoundation-000000?style=flat&logo=applemusic&logoColor=white"/>
<img src="https://img.shields.io/badge/Vision-5856D6?style=flat&logo=apple&logoColor=white"/>
</div>

### Architecture & Pattern

<div align="left">
<img src="https://img.shields.io/badge/MVC → MVVM-6E40C9?style=flat"/>
<img src="https://img.shields.io/badge/Coordinator-333333?style=flat"/>
<img src="https://img.shields.io/badge/Repository_Pattern-1B1F23?style=flat"/>
</div>

### API & Services

<div align="left">
<img src="https://img.shields.io/badge/Kakao_Book_API-FFCD00?style=flat&logo=kakao&logoColor=black"/>
<img src="https://img.shields.io/badge/Gemini_AI-4285F4?style=flat&logo=google&logoColor=white"/>
</div>

### Tools

<div align="left">
<img src="https://img.shields.io/badge/Figma-F24E1E?style=flat&logo=Figma&logoColor=white"/>
<img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=GitHub&logoColor=white"/>
<img src="https://img.shields.io/badge/Git-F05032?style=flat&logo=Git&logoColor=white"/>
</div>

---

## 🧠 Architecture

### MVC (현재) → MVVM (리팩토링 계획)

```
Phase 1 (현재)     Phase 2           Phase 3           Phase 4           Phase 5
─────────────────────────────────────────────────────────────────────────────────
UIKit + MVC    →   SwiftUI 통합   →   MVVM + RxSwift  →   Combine 전환   →   iOS 26 완성
Observable<T>      UIHostingVC        Input/Output       @Published        Liquid Glass
BaseVC             Coordinator         ViewModel          SwiftUI 6
```

### Coordinator Pattern

- `AppCoordinator`가 화면 전환 전담
- `SceneDelegate` → `AppCoordinator` → 각 화면 ViewController
- `MainTabBarController`로 탭 기반 네비게이션

### Repository Pattern

- `BookRepositoryProtocol` / `ReadingSessionRepositoryProtocol` — 프로토콜 기반 추상화
- `BookRepository` / `ReadingSessionRepository` — CoreData 구현체
- `BookEntity` · `ReadingSessionEntity` · `ConversationEntity` 확장

---

## 📦 Project Structure

```
LivingStory-iOS/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── MainTabBarController.swift
│   └── Coordinator/
│       ├── AppCoordinator.swift
│       └── Coordinator.swift              # Coordinator 프로토콜
│
├── Core/
│   ├── Components/                        # 재사용 UI
│   │   ├── ReadingLogCalendar.swift       # 읽기 캘린더
│   │   ├── ReadingTimeFormatter.swift
│   │   ├── StatCardView.swift             # 통계 카드
│   │   ├── CarouselCell.swift / FlowLayout
│   │   ├── PrimaryButton.swift
│   │   └── RadialGlowView.swift
│   ├── Consts/
│   │   ├── FontLiterals.swift
│   │   ├── GeminiPrompts.swift            # AI 프롬프트
│   │   ├── StringLiterals.swift
│   │   └── SymbolLiterals.swift
│   ├── Models/
│   │   ├── GeminiResponse.swift           # AI 응답 모델
│   │   ├── LightingConfig.swift           # 조명 설정
│   │   └── MusicCategory.swift            # 배경 음악 분류
│   ├── Network/
│   │   ├── NetworkService.swift           # URLSession 기반
│   │   ├── NetworkError.swift
│   │   ├── Config.swift                   # API Key 관리
│   │   └── ISBN/
│   │       ├── ISBNLookupService.swift    # Kakao Book API
│   │       └── KakaoBookDTO.swift
│   ├── Persistence/
│   │   ├── PersistenceController.swift    # CoreData 스택
│   │   ├── NaruModel.xcdatamodeld        # 데이터 모델
│   │   ├── Repositories/
│   │   │   ├── BookRepository.swift
│   │   │   └── ReadingSessionRepository.swift
│   │   └── Extensions/
│   │       ├── BookEntity+Extensions.swift
│   │       ├── ReadingSessionEntity+Extensions.swift
│   │       └── ConversationEntity+Extensions.swift
│   ├── Protocols/
│   │   ├── BookRepositoryProtocol.swift
│   │   └── ReadingSessionRepositoryProtocol.swift
│   ├── Services/
│   │   ├── AudioPlayerService.swift       # 배경 음악 재생
│   │   └── GeminiService.swift            # AI 대화 서비스
│   └── Storage/
│       ├── UserData.swift
│       └── UserDefaultsWrapper.swift
│
├── Model/
│   ├── BookProfileModel.swift
│   ├── ConversationProfile.swift
│   ├── DeviceModel.swift                  # HomeKit 기기
│   ├── HomeDeviceType.swift
│   ├── HomeModel.swift
│   ├── ReadingSessionProfile.swift
│   └── RoomModel.swift
│
├── Presentation/Screens/
│   ├── Onboarding/                        # 데미안 담당 (UIKit)
│   ├── Home/                              # 데미안 담당 (UIKit)
│   ├── Scanner/                           # 데미안 담당 (UIKit)
│   ├── Book/                              # 캐러셀 뷰 (UIKit)
│   ├── BookProfile/                       # 이토 담당 (SwiftUI)
│   ├── Reading/                           # 이토 담당 (SwiftUI)
│   ├── Statistics/                        # 이토 담당 (SwiftUI)
│   ├── DeviceDiscovery/                   # HomeKit 기기 검색
│   └── My/                               # 마이 페이지
│
└── Service/
```

---

## 🔗 데이터 흐름

```
[사용자]
   │
   │ ISBN 바코드 스캔
   ▼
[Scanner] ──→ [ISBNLookupService] ──→ Kakao Book API
                     │
                     ▼
              [BookRepository] ──→ CoreData (BookEntity)
                     │
                     ▼
              [Home / Book 캐러셀]
                     │
                     │ 읽기 시작
                     ▼
              [Reading 세션] ──→ [ReadingSessionRepository]
                     │
                     ├──→ [HomeKit] 조명·사운드 연출
                     ├──→ [AudioPlayerService] 배경 음악
                     └──→ [GeminiService] AI 독후감 대화
                            │
                            ▼
                     [Statistics] 읽기 통계 시각화
```

---

## 🧭 Git Flow

- `main` → 통합 브랜치
- `feat/` · `fix/` · `refactor/` · `chore/` → 기능 단위 브랜치
- PR 규칙: `feat/#이슈번호/기능명` + 코드 리뷰 필수
- 커밋 컨벤션: [COMMIT_CONVENTION.md](./docs/COMMIT_CONVENTION.md)

---

## 📘 Docs

| 문서 | 설명 |
|---|---|
| [MASTER_PLAN.md](./docs/MASTER_PLAN.md) | 리팩토링 로드맵 (MVC → MVVM → Combine) |
| [FEATURE_SPEC.md](./docs/FEATURE_SPEC.md) | 전체 기능 명세서 |
| [PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md) | 프로젝트 구조 가이드 |
| [IMPLEMENTATION_COOKBOOK.md](./docs/IMPLEMENTATION_COOKBOOK.md) | 구현 패턴 레시피 |
| [GEMINI_API_KEY_SETUP.md](./docs/GEMINI_API_KEY_SETUP.md) | Gemini API 키 설정 |
| [COMMIT_CONVENTION.md](./docs/COMMIT_CONVENTION.md) | 커밋 컨벤션 |

---

<div align="center">
<sub>Apple Developer Academy @ POSTECH · Team 기꺼이 비주류 (ProudlyOffbeat) · 2025–2026</sub>
</div>
