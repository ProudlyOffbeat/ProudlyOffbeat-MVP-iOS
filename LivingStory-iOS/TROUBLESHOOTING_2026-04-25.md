# 트러블슈팅 기록 — 2026-04-25

Naru 앱 (LivingStory-iOS) "독서 중 조명/음악/볼륨 실시간 제어" 기능 구현 과정의 문제 해결 기록.

---

## TS-01. UIKit Storyboard → Code-based 전환

### Problem
새 UIKit 프로젝트가 Storyboard 기반으로 생성되지만, 팀 컨벤션은 코드 기반 UI. Xcode 최신 버전(iOS 26) UI가 기존 튜토리얼과 달라 Main Interface 필드 위치도 바뀜.

### Approach
Storyboard 의존성을 완전히 제거하려면 4개 계층을 정리해야 함:
1. Main.storyboard 파일 자체
2. Info.plist의 Scene Manifest 내 `UISceneStoryboardFile`
3. Target General의 Main Interface 필드 (Xcode 15+ 에서 제거됨)
4. SceneDelegate의 `scene(_:willConnectTo:options:)` 내 rootViewController 수동 세팅

### Action
- Main.storyboard 파일 Project Navigator에서 Delete → Move to Trash
- Info.plist `Application Scene Manifest → Scene Configuration → Item 0 → Storyboard Name` 항목 삭제 (2개만 남김: Configuration Name, Delegate Class Name)
- Build Settings → `UIKit Main Storyboard File Base Name` 값 비우기 (General 탭엔 없어짐)
- SceneDelegate 수정: `UIWindow(windowScene:)` 생성 → `window.rootViewController = ViewController()` → `self.window = window` → `window.makeKeyAndVisible()`

### Result
- 샌드박스 프로젝트(ioT-Test) 코드 기반 UIKit 전환 완료
- 흰 배경 + 중앙 라벨 시뮬레이터 렌더 확인
- **인사이트**: Xcode 버전에 따라 UI 경로가 바뀌므로 검색은 "Main Storyboard" 키워드로 Build Settings에서 확인하는 게 안정적

---

## TS-02. 프로젝트 전환: 학습용 샌드박스 → 실제 Naru 앱

### Problem
학습용 ioT-Test에 Mock UI 만들다가, 이미 `LivingStory-iOS` (Naru 앱)에 **HomeKit 권한·바코드 스캐너·Gemini API·MVVM+Coordinator·음악 파일 10개**까지 다 구현돼 있는 걸 발견. 중복 작업 위험.

### Approach
Naru 프로젝트 구조 확인 후, 이미 존재하는 `ReadingView` + `ReadingViewModel` + `HomeKitLightingController` 에 **"실시간 컨트롤 패널"** 만 추가하는 방향으로 전환.

### Action
- Naru 프로젝트 구조 스캔: Application / Core / Model / Presentation / Service 5계층 MVVM+Coordinator 확인
- 기존 `AppLightingService` / `HomeKitLightingController` / `MusicCategory` enum / `AudioPlayerService` API 파악
- ioT-Test는 폐기하지 않고 **학습 아카이브**로 보존

### Result
- 중복 개발 회피, 기존 아키텍처 위에 증분 기능만 추가
- **교훈**: 프로젝트 시작 전 기존 코드베이스를 30분 탐색하는 투자가 수 시간 절약

---

## TS-03. Gemini API 503 "UNAVAILABLE"

### Problem
Naru 앱 실행 시 "환경세팅에 오류가 발생했어요!" 에러. Xcode 콘솔:
```json
{"error": {"code": 503, "status": "UNAVAILABLE",
 "message": "This model is currently experiencing high demand..."}}
```

### Approach
503 = 서버 과부하 = 본인 코드 문제 아님. 원인 후보:
1. 프리뷰 모델(`gemini-3-flash-preview`)에 트래픽 몰림
2. Google Cloud 광역 장애
3. API 키 발급 직후 프로비저닝 지연

Google AI Studio 상태 페이지에서 "Gemini API is having some issues serving recently created keys" 등 3개 공식 장애 확인.

### Action
- 안정 모델로 변경 계획: `GeminiService.swift:41` 의 URL을 `gemini-3-flash-preview` → `gemini-2.5-flash` 로 교체 권장
- 장애 해소까지 대기
- 재시도 로직 미구현 (과제로 남김)

### Result
- 원인 외부 요인 확인 → 디버깅 자원 낭비 안 함
- **교훈**: 프리뷰/베타 모델은 production 금지. 에러 메시지 구조(`code`/`status`/`message`) 해석이 진단의 핵심

---

## TS-04. 시뮬레이터에서 HomeKit이 Mock만 쓰이는 문제

### Problem
실기기 iPhone에 빌드해도 HomeKit 연동이 안 되고 콘솔엔 `[MockLighting]` 로그만 찍힘. 실제 전구 제어 불가.

### Approach
`AppCoordinator.swift:110` 와 `AppLightingService.swift:24` 의 분기 코드 확인:
```swift
#if DEBUG
lightingController = MockLightingController()
#else
lightingController = HomeKitLightingController()
#endif
```

`#if DEBUG` 는 **Debug 빌드 configuration에서 항상 참**. ⌘R은 기본 Debug → **실기기에서도 Mock 사용**.

### Action
분기 조건을 **빌드 configuration 기반 → 실행 환경 기반** 으로 변경:
```swift
#if targetEnvironment(simulator)
lightingController = MockLightingController()
#else
lightingController = HomeKitLightingController()
#endif
```

두 파일 동일하게 수정.

### Result
- 실기기에서 Debug 빌드로 실제 HomeKit 제어 가능
- 시뮬레이터는 여전히 Mock 유지 (HomeKit 미지원)
- **교훈**: `#if DEBUG` 는 "개발 중이냐"지 "시뮬레이터냐"가 아님. 의도 구별 필요

---

## TS-05. WiZ 전구 과부하 → "조명 적용 실패" 연쇄

### Problem
슬라이더 실시간 드래그 시 수십 개 "조명 적용 실패" 로그. 30초 후 Apple Home에서 "응답없음" 표시. 1-2분 대기 후 자가복구 반복.

### Approach
시간당 write 수 분석:
- 슬라이더 60fps × 1초 = 60 이벤트
- 초기 디바운스 80ms × 1 apply = 초당 10 apply
- 각 apply 내부에서 **Power + Hue + Saturation + Brightness = 4 writeValue**
- 총 **40 writes/sec**, WiZ 안정 한계 10-20/sec의 2-4배 초과

원인 3개:
1. 슬라이더 드래그 중 continuous write
2. 변경 없는 characteristic도 매번 write (Power=true, 불변 값들)
3. 쓰로틀 로직이 실제로는 디바운스로 동작 (`pendingLightingTask?.cancel()`이 매 이벤트마다 실행되어 연속 드래그 시 Task가 계속 취소됨)

### Action
5단계 최적화:
1. **디바운스 → 쓰로틀** (Leading + Trailing 구조):
   ```swift
   if elapsed >= throttleInterval {
       // 즉시 전송, lastSentTime 갱신
   } else if pendingLightingTask == nil {
       // 예약 없을 때만 trailing 예약
   } else {
       // 이미 예약됨 → pendingLightingConfig만 최신값으로 업데이트
   }
   ```
2. **이중 쓰로틀**: 밝기 200ms (1 characteristic) / 색상 250ms (2 characteristic) — 색상환 드래그 시 Hue+Sat 둘 다 바뀌어 write 2배라 더 긴 간격 적용
3. **Diff write**: `HomeKitLightingController` 에 `lastAppliedConfig` / `lastPowerState` 추적 추가, 이전 값과 같으면 writeValue skip
4. **Slider `onEditingChanged`**: 손 뗄 때 `commitLighting()` 호출 → 쓰로틀/디바운스 건너뛰고 즉시 최종값 전송 (밝기 release 시 300ms 절감)
5. **`#if DEBUG` → `#if targetEnvironment(simulator)`**: 실기기 Debug 빌드에서도 실제 HomeKit 제어 (TS-04 연계)

### Result
| 지표 | 이전 | 이후 |
|------|------|------|
| 초당 writes (슬라이더 드래그) | 40+ | 5-10 |
| 평균 응답시간 | 600-1500ms | 100-300ms |
| "응답없음" 발생 빈도 | 30초마다 | 거의 없음 |
| 실패 로그 비율 | 드래그 시 대부분 | 0-5% |

**교훈**: 
- 쓰로틀과 디바운스는 이름은 비슷하지만 동작이 반대 (주기적 vs 멈출 때까지)
- IoT는 **하드웨어 한계가 SW UX를 제약**하므로, "실시간"은 항상 10Hz 이하로 타협
- 다중 characteristic은 write 수를 **characteristic 수만큼 곱해서** 계산해야 함

---

## TS-06. WiZ 전구 페어링 실패 (전 사용자 인수)

### Problem
중고로 받은 WiZ 전구가 Apple Home에 페어링 안 됨. 전 사용자가 WiZ 앱에서 삭제 + Matter 세팅도 지웠다는데도 물리 리셋 5번 해도 **파란색 펄스 신호 없이 노란색만 깜빡**.

### Approach
WiZ/Matter 전구는 **3중 바인딩** 가능:
1. WiZ 클라우드 계정
2. Matter fabric (Apple/Google/SmartThings)
3. 전구 내부 펌웨어 메모리

"삭제 했다"고 해서 **3개가 다 지워졌다는 뜻이 아님**. 특히 본인이 과거에 페어링한 적 있으면 **본인 홈 허브(HomePod) 에도 잔재** 남아있을 가능성.

### Action
양쪽 잔재 체크리스트 실행:
- **본인 쪽**: 홈 앱 → 홈 허브 및 브리지 → Matter 섹션 확인 → 오래된 항목 제거
- **전 사용자 쪽**: WiZ 앱 모든 방 확인 (Offline 포함), 홈 앱의 "액세서리 제거" (방 제거 아님)
- **물리 리셋**: 스탠드 스위치 (버튼식, 기계식) 로 정확히 5사이클, 1초 간격
- 리셋 신호 구분:
  - 노란색 유지 = 리셋 실패
  - 파란색 펄스/색 순환 = 페어링 모드 진입

### Result
- 10번 이상 시도 후 파란색 펄스 확인 → Apple Home에서 페어링 시도
- 초기 "Pairing Failed" → HomePod 재시작 + iPhone Wi-Fi 2.4GHz 확인 후 성공
- **교훈**: IoT 중고 인수 시 "소프트 삭제" 로는 부족. **반드시 물리 리셋**. 신호 색상은 제품별로 다르니 WiZ = 파란색 펄스 기억

---

## TS-07. HomeKit 외부 변경이 앱 UI에 반영 안 됨

### Problem
Apple Home 앱에서 조명 토글하면 실제 전구는 빠르게 반응하지만, Naru 앱의 홈 화면 카드 UI는 상태가 갱신 안 됨.

### Approach
코드 경로 추적:
- `HomeViewController.didSelectItemAt` → `togglePower` → `characteristic.writeValue` ✅
- `HMAccessoryDelegate.accessory(_:service:didUpdateValueFor:)` → 이게 **외부 변경 감지 진입점**
- `enableNotification(true)` 이 호출되려면 characteristic이 `HMCharacteristicPropertySupportsEventNotification` 속성을 노출해야 함

**WiZ Matter 펌웨어가 Event Notification 속성을 inconsistent하게 제공** — 지원한다고 하고 실제로 이벤트 안 보내거나, 속성 자체를 안 노출하는 버전 있음.

### Approach (대안)
Apple Home 앱도 같은 한계를 **낙관적 UI 업데이트 + 주기적 readValue 폴링** 으로 우회.

### Action
해결책 3가지 제안:
1. **낙관적 업데이트 (best UX)**: 탭 즉시 로컬 state 토글 → UI 갱신 → 실패 시 롤백
2. **`readValue` 강제 호출**: `writeValue` 직후 `readValue` 를 추가로 호출 → delegate 강제 발동
3. **하이브리드**: 1 + 2

### Result
- 근본 원인 파악 완료 (WiZ Matter 펌웨어 한계)
- 구현은 time box 초과로 보류 — 다음 세션 과제
- **교훈**: HomeKit "실시간 동기화"는 **벤더 펌웨어에 의존**하는 취약한 부분. 낙관적 UI가 실무 해법

---

## TS-08. SwiftUI ColorPicker가 사각형 — Apple Home 원형 UI 모사

### Problem
Apple Home의 색상 선택 팔레트는 **원형 (angular + radial gradient)** 인데, SwiftUI의 `ColorPicker` 는 **사각 그라디언트**. UX 일관성 부족.

초기 시도: `Canvas` 에 `for x, y` 픽셀 단위 HSB 계산 → **GPU/CPU 과부하로 뷰 크래시** ("원을 그리면 터진다").

### Approach
픽셀 렌더링 포기, **벡터 그라디언트 합성**:
- `AngularGradient` = 각도별 Hue (빨→노→초→청→파→자→빨)
- `RadialGradient` = 중심 흰색 → 외곽 투명 (채도 표현)
- 두 `Circle` 을 ZStack으로 겹치면 HSB 2D 평면 완성
- `DragGesture` + `atan2` 로 터치 위치 → Hue/Saturation 역산

### Action
`CircularColorWheel` 컴포넌트 신규 작성 (약 90줄):
```swift
ZStack {
    Circle().fill(AngularGradient(...))       // Hue
    Circle().fill(RadialGradient(...))        // Saturation
    Circle().strokeBorder(.white, lineWidth: 3)  // 인디케이터
}
.gesture(DragGesture(minimumDistance: 0).onChanged { value in
    let dx = value.location.x - radius
    let dy = value.location.y - radius
    let dist = min(sqrt(dx*dx + dy*dy), radius)
    var angle = atan2(dy, dx) * 180 / .pi
    if angle < 0 { angle += 360 }
    onChange(Int(angle) % 360, Int((dist/radius) * 100))
})
```

팔레트 마지막 "커스텀" 버튼 탭 시 Sheet로 표시, 기존 throttle 로직(250ms 색상 쓰로틀)과 자동 연동.

### Result
- Apple Home과 거의 동일한 UX 달성 (원형, 드래그 실시간 반응)
- **60fps 유지** (Metal GPU 가속 벡터 렌더링 덕분)
- Canvas 픽셀 루프 대비 **성능 수십 배 개선**
- 크래시 완전 해결
- **교훈**: 2D 그래픽은 **픽셀 단위 계산 금지**, 벡터 shape + gradient 조합으로 대체

---

## 전체 요약 표

| # | 문제 | 근본 원인 | 해법 | 수치 효과 |
|---|------|---------|------|---------|
| 01 | UIKit 코드 전환 | Storyboard 기본 템플릿 | 4계층 제거 | — |
| 02 | 샌드박스 vs 실제 | 코드베이스 미파악 | 기존 프로젝트 탐색 | 수 시간 절약 |
| 03 | Gemini 503 | 프리뷰 모델 과부하 | 안정 모델로 변경 | 외부 장애 회피 |
| 04 | Mock만 쓰임 | `#if DEBUG` 오해 | `#if targetEnvironment(simulator)` | 실기기 HomeKit 활성 |
| 05 | 조명 적용 실패 | 초당 40+ writes | 쓰로틀 + Diff write + commit | 40→8 writes/sec |
| 06 | 페어링 실패 | 전구 내부 잔재 | 물리 리셋 5사이클 | 페어링 성공 |
| 07 | UI 동기화 안 됨 | WiZ Matter Notification 미지원 | 낙관적 UI (보류) | 진단 완료 |
| 08 | 색상환 크래시 | Canvas 픽셀 루프 | 벡터 그라디언트 | 60fps 달성 |

---

## 얻은 기술 인사이트

1. **IoT = 하드웨어가 SW UX를 좌우한다** — WiZ 전구의 초당 write 한계가 슬라이더 쓰로틀 간격을 결정.
2. **쓰로틀 ≠ 디바운스** — 연속 조작 UX 구현 시 두 개념 구별이 결정적.
3. **Event Notification은 벤더 의존적** — 표준 준수한다고 해서 모든 기능 동작 보장 아님. 우회책 필수.
4. **"삭제" 는 소프트웨어 삭제** — 하드웨어 바인딩은 별개, 물리 리셋 필수.
5. **SwiftUI 그래픽은 벡터로** — 픽셀 루프는 성능 지옥, 그라디언트 합성이 해법.
6. **빌드 configuration ≠ 실행 환경** — `#if DEBUG` 오용 주의.
7. **UX 일관성의 숨은 비용** — "Apple 앱처럼 만들기" 는 내부 구현 추측 + 자체 구현 필요.
