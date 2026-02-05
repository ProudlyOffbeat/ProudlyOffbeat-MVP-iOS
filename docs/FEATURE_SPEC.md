# 📋 기능명세서 (Feature Specification)

> LivingStory-iOS 전체 기능 명세

---

## 📱 화면 목록

| ID | 화면명 | 프레임워크 | 담당 | 우선순위 |
|----|-------|----------|-----|---------|
| ONB | 온보딩 | UIKit | 데미안 | P0 |
| HOM | 홈 | UIKit | 데미안 | P0 |
| SCN | 스캐너 | UIKit | 데미안 | P0 |
| BKP | 책 프로필 | SwiftUI | 이토 | P1 |
| RDG | 책 읽기 | SwiftUI | 이토 | P1 |
| STS | 통계 | SwiftUI | 이토 | P2 |
| STG | 설정 | UIKit | 공통 | P2 |

---

## 🚀 ONB: 온보딩

### ONB-001: 앱 소개 페이지

**화면 설명**: 앱 첫 실행 시 보여지는 소개 페이지 (3페이지 스와이프)

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| ONB-001-UI-01 | scrollView | UIScrollView | 페이지 스와이프 |
| ONB-001-UI-02 | pageControl | UIPageControl | 현재 페이지 인디케이터 |
| ONB-001-UI-03 | nextButton | UIButton | "다음" / "시작하기" |
| ONB-001-UI-04 | skipButton | UIButton | "건너뛰기" |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| ONB-001-F01 | 페이지 스와이프 | 좌우 스와이프로 페이지 전환 | P0 |
| ONB-001-F02 | 페이지 인디케이터 | 현재 페이지 표시 | P0 |
| ONB-001-F03 | 다음 버튼 | 다음 페이지로 이동, 마지막 페이지에서 "시작하기" | P0 |
| ONB-001-F04 | 건너뛰기 | 온보딩 완료 처리 후 홈 이동 | P1 |

**비즈니스 로직**:
```
IF 마지막 페이지 THEN
    nextButton.title = "시작하기"
    skipButton.isHidden = true
ELSE
    nextButton.title = "다음"
    skipButton.isHidden = false
```

---

### ONB-002: HomeKit 권한 요청

**화면 설명**: HomeKit 접근 권한 요청 화면

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| ONB-002-UI-01 | iconImageView | UIImageView | HomeKit 아이콘 |
| ONB-002-UI-02 | titleLabel | UILabel | "스마트 기기 연결" |
| ONB-002-UI-03 | descriptionLabel | UILabel | 권한 필요 설명 |
| ONB-002-UI-04 | allowButton | UIButton | "권한 허용" |
| ONB-002-UI-05 | laterButton | UIButton | "나중에" |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| ONB-002-F01 | 권한 요청 | HMHomeManager 초기화로 권한 요청 | P0 |
| ONB-002-F02 | 권한 승인 | 기기 검색 화면으로 이동 | P0 |
| ONB-002-F03 | 권한 거부 | 설정 앱 이동 안내 Alert | P0 |
| ONB-002-F04 | 나중에 | 권한 없이 홈 화면 이동 | P1 |

**API 연동**:
```swift
// HomeKit 권한 요청
HMHomeManager() // 초기화 시 자동으로 권한 요청 팝업
```

---

### ONB-003: 기기 검색 및 등록

**화면 설명**: HomeKit 호환 기기 자동 검색 및 선택

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| ONB-003-UI-01 | headerLabel | UILabel | "기기 검색 중..." |
| ONB-003-UI-02 | progressView | UIProgressView | 검색 진행률 |
| ONB-003-UI-03 | tableView | UITableView | 발견된 기기 목록 |
| ONB-003-UI-04 | completeButton | UIButton | "완료" |
| ONB-003-UI-05 | rescanButton | UIButton | "다시 검색" |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| ONB-003-F01 | 기기 검색 | 10초간 HomeKit 기기 자동 검색 | P0 |
| ONB-003-F02 | 검색 진행률 | 프로그레스 바로 진행률 표시 | P1 |
| ONB-003-F03 | 기기 목록 | 발견된 기기 목록 표시 | P0 |
| ONB-003-F04 | 기기 선택 | 기기 탭하여 선택/해제 | P0 |
| ONB-003-F05 | 완료 | 선택한 기기 저장 후 홈 이동 | P0 |
| ONB-003-F06 | 다시 검색 | 기기 목록 초기화 후 재검색 | P1 |

**상태 다이어그램**:
```
[Idle] → 화면진입 → [Scanning] → 10초경과 → [Completed]
                         ↓
                    기기발견 → [DeviceFound]
                         ↓
                    사용자선택 → [Selected]
```

---

## 🏠 HOM: 홈

### HOM-001: 메인 홈 화면

**화면 설명**: 등록된 방과 기기를 관리하는 메인 화면

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| HOM-001-UI-01 | collectionView | UICollectionView | 방/기기 목록 |
| HOM-001-UI-02 | scanButton | UIButton | "책 스캔하기" FAB |
| HOM-001-UI-03 | statisticsButton | UIBarButtonItem | 통계 화면 이동 |

**섹션 구성**:
| 섹션 | 내용 | 셀 타입 |
|-----|------|--------|
| 0 | 방 목록 | RoomCell (2열 그리드) |
| 1 | 기기 목록 | DeviceCell (1열 리스트) |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| HOM-001-F01 | 방 목록 표시 | 등록된 방 목록 그리드 표시 | P0 |
| HOM-001-F02 | 기기 목록 표시 | 등록된 기기 목록 표시 | P0 |
| HOM-001-F03 | 기기 전원 토글 | 스위치로 기기 On/Off | P0 |
| HOM-001-F04 | 스캔 버튼 | Scanner 화면 이동 | P0 |
| HOM-001-F05 | 통계 버튼 | Statistics 화면 이동 | P1 |
| HOM-001-F06 | Pull to Refresh | 당겨서 새로고침 | P1 |

**데이터 흐름**:
```
viewDidLoad → loadData() → Repository.fetchRooms()
                        → Repository.fetchDevices()
                        → Observable.bind() → UI 업데이트
```

---

## 📷 SCN: 스캐너

### SCN-001: 바코드 스캔 화면

**화면 설명**: ISBN 바코드를 카메라로 스캔하는 화면

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| SCN-001-UI-01 | previewView | UIView | 카메라 프리뷰 |
| SCN-001-UI-02 | overlayView | ScannerOverlayView | 스캔 영역 표시 |
| SCN-001-UI-03 | instructionLabel | UILabel | "바코드를 맞춰주세요" |
| SCN-001-UI-04 | flashButton | UIButton | 플래시 토글 |
| SCN-001-UI-05 | manualInputButton | UIButton | "ISBN 직접 입력" |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| SCN-001-F01 | 카메라 프리뷰 | 실시간 카메라 화면 표시 | P0 |
| SCN-001-F02 | 바코드 인식 | EAN-13 (ISBN) 바코드 인식 | P0 |
| SCN-001-F03 | ISBN 검증 | 978/979 접두사 확인 | P0 |
| SCN-001-F04 | 인식 성공 | 햅틱 피드백 + 책 정보 조회 | P0 |
| SCN-001-F05 | 플래시 토글 | 어두운 환경에서 플래시 사용 | P1 |
| SCN-001-F06 | 수동 입력 | ISBN 직접 입력 Alert | P1 |
| SCN-001-F07 | 권한 체크 | 카메라 권한 확인/요청 | P0 |

**에러 처리**:
| 에러 코드 | 상황 | 처리 |
|----------|-----|------|
| SCN-E01 | 카메라 권한 없음 | 설정 앱 이동 안내 |
| SCN-E02 | 카메라 사용 불가 | 에러 메시지 표시 |
| SCN-E03 | ISBN 조회 실패 | 재시도 안내 |

---

## 📖 BKP: 책 프로필 (SwiftUI)

### BKP-001: 책 정보 화면

**화면 설명**: 스캔한 책의 상세 정보 및 조명 프리셋 선택

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| BKP-001-UI-01 | coverImage | AsyncImage | 책 표지 이미지 |
| BKP-001-UI-02 | titleText | Text | 책 제목 |
| BKP-001-UI-03 | authorText | Text | 저자 |
| BKP-001-UI-04 | categoryTag | Capsule | 분위기 카테고리 |
| BKP-001-UI-05 | presetPicker | HStack | 색상 프리셋 선택 |
| BKP-001-UI-06 | summaryText | Text | 줄거리 |
| BKP-001-UI-07 | startButton | Button | "책 읽기 시작" |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| BKP-001-F01 | 책 정보 표시 | 제목, 저자, 출판사, ISBN 표시 | P0 |
| BKP-001-F02 | 표지 이미지 | 비동기 이미지 로딩 | P1 |
| BKP-001-F03 | 카테고리 표시 | AI 분류된 분위기 카테고리 | P0 |
| BKP-001-F04 | 프리셋 선택 | 조명 색상 프리셋 변경 | P0 |
| BKP-001-F05 | 프리셋 미리보기 | 선택한 색상 미리보기 | P1 |
| BKP-001-F06 | 읽기 시작 | Reading 화면 이동 + 조명 적용 | P0 |

---

## ⏱ RDG: 책 읽기 (SwiftUI)

### RDG-001: 독서 진행 화면

**화면 설명**: 책 읽기 진행 중 타이머 및 조명 제어

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| RDG-001-UI-01 | backgroundGradient | LinearGradient | 프리셋 색상 배경 |
| RDG-001-UI-02 | bookInfo | VStack | 책 제목, 저자 |
| RDG-001-UI-03 | timerText | Text | 경과 시간 |
| RDG-001-UI-04 | moodIndicator | HStack | 현재 분위기 표시 |
| RDG-001-UI-05 | pauseButton | Button | 일시정지 |
| RDG-001-UI-06 | stopButton | Button | 종료 |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| RDG-001-F01 | 타이머 | 독서 시간 카운트 (초 단위) | P0 |
| RDG-001-F02 | 배경 색상 | 프리셋에 맞는 그라데이션 배경 | P0 |
| RDG-001-F03 | 일시정지 | 타이머 일시정지/재개 | P0 |
| RDG-001-F04 | 종료 확인 | 종료 시 확인 다이얼로그 | P0 |
| RDG-001-F05 | 세션 저장 | 종료 시 ReadingSession 저장 | P0 |
| RDG-001-F06 | 조명 복귀 | 종료 시 조명 기본값 복귀 (선택) | P2 |

---

## 📊 STS: 통계 (SwiftUI)

### STS-001: 독서 통계 화면

**화면 설명**: 독서 기록 및 통계 확인

**UI 구성요소**:
| ID | 컴포넌트 | 타입 | 설명 |
|----|---------|-----|------|
| STS-001-UI-01 | summaryCards | HStack | 요약 카드 (총 책, 시간, 이번 달) |
| STS-001-UI-02 | calendarView | CalendarGridView | 월간 캘린더 |
| STS-001-UI-03 | recentBooksList | List | 최근 읽은 책 |
| STS-001-UI-04 | categoryChart | VStack | 카테고리별 통계 |

**기능 요구사항**:
| ID | 기능 | 설명 | 우선순위 |
|----|-----|------|---------|
| STS-001-F01 | 요약 카드 | 총 읽은 책, 총 시간, 이번 달 표시 | P0 |
| STS-001-F02 | 캘린더 | 독서한 날짜 마킹 | P1 |
| STS-001-F03 | 월 이동 | 이전/다음 달 이동 | P1 |
| STS-001-F04 | 최근 책 | 최근 읽은 책 5권 표시 | P0 |
| STS-001-F05 | 카테고리 통계 | 분위기별 독서 횟수 차트 | P2 |

---

## 🔗 화면 전환 흐름

```
앱 시작
    │
    ├── 온보딩 미완료 ──→ ONB-001 → ONB-002 → ONB-003 → HOM-001
    │
    └── 온보딩 완료 ────→ HOM-001
                            │
                            ├── 스캔 버튼 ──→ SCN-001 → BKP-001 → RDG-001
                            │                              │
                            │                              └── 종료 → HOM-001
                            │
                            └── 통계 버튼 ──→ STS-001

딥링크:
    livingstory://book/{isbn} → SCN-001 → BKP-001
    livingstory://reading/{sessionId} → RDG-001
```

---

## 📡 API 명세

### ISBN 책 정보 조회

**Endpoint**: 국립중앙도서관 API

```
GET https://www.nl.go.kr/seoji/SearchApi.do
```

**Request Parameters**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|-----|-----|------|
| cert_key | String | Y | API 인증키 |
| result_style | String | Y | "json" |
| page_no | Int | Y | 1 |
| page_size | Int | Y | 1 |
| isbn | String | Y | ISBN 번호 |

**Response**:
```json
{
  "TOTAL_COUNT": "1",
  "docs": [
    {
      "EA_ISBN": "9788937460470",
      "TITLE": "어린 왕자",
      "AUTHOR": "생텍쥐페리",
      "PUBLISHER": "문학동네",
      "PUBLISH_PREDATE": "20150601",
      "PAGE": "127"
    }
  ]
}
```

---

## 💾 데이터 모델

### CoreData Entities

```
BookEntity
├── id: UUID (PK)
├── isbn: String
├── title: String
├── author: String
├── publisher: String?
├── coverURL: String?
├── summary: String?
├── category: String
├── createdAt: Date

DeviceEntity
├── id: UUID (PK)
├── homeKitId: UUID?
├── name: String
├── type: String (light/speaker)
├── roomId: UUID? (FK)
├── isReachable: Bool

RoomEntity
├── id: UUID (PK)
├── homeKitId: UUID?
├── name: String
├── iconName: String

ReadingSessionEntity
├── id: UUID (PK)
├── bookId: UUID (FK)
├── startedAt: Date
├── endedAt: Date?
├── colorPresetName: String
├── status: String
```

---

**문서 버전**: 1.0
**최종 수정**: 2026-01-30