# 🍳 Implementation Cookbook

> 실제 코딩할 때 보는 실무 가이드

---

## 📁 폴더 구조 & 파일 위치

```
LivingStory-iOS/
├── Application/
│   ├── AppDelegate.swift          # 앱 시작점
│   ├── SceneDelegate.swift        # Scene 관리 + Deep Link
│   └── DIContainer.swift          # ⭐ 모든 의존성 여기서 생성
│
├── Core/
│   ├── Protocols/
│   │   └── Observable.swift       # MVC 바인딩
│   └── Extensions/
│       └── UIView+Extensions.swift
│
├── Domain/                        # 🏛 비즈니스 로직 (순수 Swift)
│   ├── Entities/
│   │   ├── Book.swift
│   │   ├── Room.swift
│   │   └── Device.swift
│   ├── Protocols/
│   │   └── RepositoryProtocols.swift  # Repository 인터페이스
│   └── UseCases/
│       └── UseCases.swift         # 비즈니스 로직 캡슐화
│
├── Data/                          # 💾 데이터 접근
│   ├── Repositories/
│   │   ├── BookRepository.swift   # Protocol 구현체
│   │   └── RoomRepository.swift
│   ├── DataSources/
│   │   ├── Local/
│   │   │   └── CoreDataManager.swift
│   │   └── Remote/
│   │       └── BookAPIService.swift
│   └── DTOs/
│       └── BookDTO.swift          # API 응답 모델
│
├── Infrastructure/                # 🔧 기술적 서비스
│   ├── Network/
│   │   └── NetworkService.swift
│   ├── HomeKit/
│   │   └── HomeKitManager.swift
│   └── Scanner/
│       └── BarcodeScanner.swift
│
└── Presentation/                  # 📱 UI 레이어
    ├── Common/
    │   ├── Base/
    │   │   └── BaseViewController.swift
    │   ├── Components/
    │   │   ├── PrimaryButton.swift
    │   │   └── LoadingView.swift
    │   └── UIKitSwiftUIBridge.swift
    ├── Coordinators/
    │   ├── Coordinator.swift      # Protocol
    │   ├── AppCoordinator.swift   # 루트 Coordinator
    │   └── HomeCoordinator.swift
    └── Scenes/
        ├── Home/
        │   ├── HomeViewController.swift
        │   ├── HomeViewModel.swift      # MVVM 전환 후
        │   └── SubViews/
        │       └── RoomCell.swift
        ├── Scanner/
        │   └── ScannerViewController.swift
        └── BookProfile/
            └── BookProfileView.swift    # SwiftUI
```

---

## 🔄 DI (의존성 주입) 흐름도

### 전체 흐름

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DIContainer                                  │
│  (모든 의존성의 시작점 - Application/DIContainer.swift)              │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
   ┌──────────┐         ┌──────────┐         ┌──────────┐
   │Repository│         │ Service  │         │ UseCase  │
   │ 생성     │         │ 생성     │         │ 생성     │
   └────┬─────┘         └────┬─────┘         └────┬─────┘
        │                    │                    │
        │         ┌──────────┴──────────┐        │
        │         ▼                     ▼        │
        │   ┌──────────┐         ┌──────────┐   │
        │   │HomeKit   │         │ Network  │   │
        │   │Manager   │         │ Service  │   │
        │   └──────────┘         └──────────┘   │
        │                                        │
        └────────────────┬───────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   AppCoordinator    │
              │  (DIContainer 주입) │
              └──────────┬──────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
   ┌───────────┐   ┌───────────┐   ┌───────────┐
   │ Home      │   │ Scanner   │   │ BookProfile│
   │Coordinator│   │Coordinator│   │Coordinator │
   └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
         │               │               │
         ▼               ▼               ▼
   ┌───────────┐   ┌───────────┐   ┌───────────┐
   │ ViewController │ ViewController │ SwiftUI   │
   │ (UseCase 주입) │ (UseCase 주입) │ View      │
   └───────────┘   └───────────┘   └───────────┘
```

### 주입 포인트 상세

```swift
// 1️⃣ DIContainer.swift - 모든 것의 시작
@MainActor
final class DIContainer {
    static let shared = DIContainer()

    // 서비스들 (lazy로 필요할 때 생성)
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var homeKitManager: HomeKitManagerProtocol = HomeKitManager()

    // Repository들 (서비스를 주입받음)
    lazy var bookRepository: BookRepositoryProtocol = {
        BookRepository(
            remoteDataSource: BookAPIService(networkService: networkService),
            localDataSource: BookLocalDataSource()
        )
    }()

    // UseCase 팩토리 메서드 (Repository를 주입)
    func makeScanBookUseCase() -> ScanBookUseCase {
        ScanBookUseCase(
            scannerService: BarcodeScanner(),
            bookRepository: bookRepository
        )
    }
}

// 2️⃣ SceneDelegate.swift - Coordinator 시작
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, ...) {
    let navigationController = UINavigationController()

    // DIContainer를 AppCoordinator에 주입
    appCoordinator = AppCoordinator(
        navigationController: navigationController,
        diContainer: DIContainer.shared  // ⭐ 여기서 주입
    )
    appCoordinator?.start()
}

// 3️⃣ AppCoordinator.swift - 자식 Coordinator에 전달
final class AppCoordinator: Coordinator {
    private let diContainer: DIContainer

    func showHome() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            diContainer: diContainer  // ⭐ 자식에게 전달
        )
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
}

// 4️⃣ HomeCoordinator.swift - ViewController에 UseCase 주입
final class HomeCoordinator: Coordinator {
    private let diContainer: DIContainer

    func start() {
        let useCase = diContainer.makeLoadRoomsUseCase()
        let viewController = HomeViewController(
            loadRoomsUseCase: useCase  // ⭐ VC에 주입
        )
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
}

// 5️⃣ HomeViewController.swift - 주입받은 UseCase 사용
final class HomeViewController: BaseViewController {
    private let loadRoomsUseCase: LoadRoomsUseCase

    init(loadRoomsUseCase: LoadRoomsUseCase) {
        self.loadRoomsUseCase = loadRoomsUseCase  // ⭐ 주입받음
        super.init(nibName: nil, bundle: nil)
    }

    func loadData() {
        Task {
            let rooms = try await loadRoomsUseCase.execute()
            // UI 업데이트
        }
    }
}
```

---

## 📝 새 화면 추가하기 (Step by Step)

### 예시: "독서 기록" 화면 추가

#### Step 1: Entity 생성 (필요한 경우)
```
📁 Domain/Entities/ReadingRecord.swift
```

```swift
struct ReadingRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let bookId: UUID
    let startTime: Date
    let endTime: Date
    let pagesRead: Int
}
```

#### Step 2: Repository Protocol 추가
```
📁 Domain/Protocols/RepositoryProtocols.swift 에 추가
```

```swift
protocol ReadingRecordRepositoryProtocol: Sendable {
    func fetchRecords(bookId: UUID) async throws -> [ReadingRecord]
    func saveRecord(_ record: ReadingRecord) async throws
}
```

#### Step 3: Repository 구현체 생성
```
📁 Data/Repositories/ReadingRecordRepository.swift
```

```swift
final class ReadingRecordRepository: ReadingRecordRepositoryProtocol {
    private let localDataSource: ReadingRecordLocalDataSource

    init(localDataSource: ReadingRecordLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchRecords(bookId: UUID) async throws -> [ReadingRecord] {
        try await localDataSource.fetch(bookId: bookId)
    }

    func saveRecord(_ record: ReadingRecord) async throws {
        try await localDataSource.save(record)
    }
}
```

#### Step 4: UseCase 생성
```
📁 Domain/UseCases/UseCases.swift 에 추가
```

```swift
final class SaveReadingRecordUseCase: Sendable {
    private let repository: ReadingRecordRepositoryProtocol

    init(repository: ReadingRecordRepositoryProtocol) {
        self.repository = repository
    }

    func execute(bookId: UUID, pagesRead: Int, duration: TimeInterval) async throws {
        let record = ReadingRecord(
            id: UUID(),
            bookId: bookId,
            startTime: Date().addingTimeInterval(-duration),
            endTime: Date(),
            pagesRead: pagesRead
        )
        try await repository.saveRecord(record)
    }
}
```

#### Step 5: DIContainer에 등록
```
📁 Application/DIContainer.swift 에 추가
```

```swift
// Repository
lazy var readingRecordRepository: ReadingRecordRepositoryProtocol = {
    ReadingRecordRepository(
        localDataSource: ReadingRecordLocalDataSource()
    )
}()

// UseCase Factory
func makeSaveReadingRecordUseCase() -> SaveReadingRecordUseCase {
    SaveReadingRecordUseCase(repository: readingRecordRepository)
}
```

#### Step 6: ViewController 생성
```
📁 Presentation/Scenes/ReadingRecord/ReadingRecordViewController.swift
```

```swift
@MainActor
final class ReadingRecordViewController: BaseViewController {

    // MARK: - Properties
    weak var coordinator: ReadingRecordCoordinator?
    private let saveUseCase: SaveReadingRecordUseCase
    private let book: Book

    // MARK: - UI
    private let pagesTextField = UITextField()
    private let saveButton = UIButton()

    // MARK: - Init
    init(book: Book, saveUseCase: SaveReadingRecordUseCase) {
        self.book = book
        self.saveUseCase = saveUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func setupLayout() {
        view.addSubview(pagesTextField)
        view.addSubview(saveButton)
    }

    override func setupConstraints() {
        // AutoLayout 코드
        pagesTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pagesTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pagesTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pagesTextField.widthAnchor.constraint(equalToConstant: 200),

            saveButton.topAnchor.constraint(equalTo: pagesTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func bind() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let pagesText = pagesTextField.text,
              let pages = Int(pagesText) else { return }

        Task {
            showLoading()
            do {
                try await saveUseCase.execute(
                    bookId: book.id,
                    pagesRead: pages,
                    duration: 1800 // 30분
                )
                hideLoading()
                coordinator?.didSaveRecord()
            } catch {
                hideLoading()
                showError(error.localizedDescription)
            }
        }
    }
}
```

#### Step 7: Coordinator 생성
```
📁 Presentation/Coordinators/ReadingRecordCoordinator.swift
```

```swift
@MainActor
protocol ReadingRecordCoordinatorDelegate: AnyObject {
    func readingRecordDidFinish(_ coordinator: ReadingRecordCoordinator)
}

@MainActor
final class ReadingRecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    weak var delegate: ReadingRecordCoordinatorDelegate?

    private let diContainer: DIContainer
    private let book: Book

    init(
        navigationController: UINavigationController,
        diContainer: DIContainer,
        book: Book
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.book = book
    }

    func start() {
        let useCase = diContainer.makeSaveReadingRecordUseCase()
        let viewController = ReadingRecordViewController(
            book: book,
            saveUseCase: useCase
        )
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func finish() {
        delegate?.readingRecordDidFinish(self)
    }

    func didSaveRecord() {
        navigationController.popViewController(animated: true)
        finish()
    }
}
```

#### Step 8: 부모 Coordinator에서 호출
```
📁 Presentation/Coordinators/BookProfileCoordinator.swift
```

```swift
func showReadingRecord(for book: Book) {
    let coordinator = ReadingRecordCoordinator(
        navigationController: navigationController,
        diContainer: diContainer,
        book: book
    )
    coordinator.delegate = self
    childCoordinators.append(coordinator)
    coordinator.start()
}

// Delegate
extension BookProfileCoordinator: ReadingRecordCoordinatorDelegate {
    func readingRecordDidFinish(_ coordinator: ReadingRecordCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
```

---

## 🎯 완전한 예제: 버튼 탭 → API → UI 업데이트

### 시나리오: "책 스캔" 버튼 탭 → ISBN 스캔 → API 조회 → 책 정보 표시

```
사용자 액션                    코드 흐름
─────────────────────────────────────────────────────────────────

[스캔 버튼 탭]
     │
     ▼
HomeViewController            @objc func scanButtonTapped() {
     │                            coordinator?.showScanner()
     │                        }
     ▼
HomeCoordinator              func showScanner() {
     │                           let coordinator = ScannerCoordinator(...)
     │                           coordinator.delegate = self
     │                           coordinator.start()
     │                       }
     ▼
ScannerCoordinator           func start() {
     │                           let useCase = diContainer.makeScanBookUseCase()
     │                           let vc = ScannerViewController(useCase: useCase)
     │                           vc.coordinator = self
     │                           navigationController.push(vc)
     │                       }
     ▼
ScannerViewController        // 카메라로 바코드 스캔
     │                       func metadataOutput(..., metadataObjects: ...) {
     │                           guard let isbn = extractISBN(from: metadataObjects)
     │                           scanISBN(isbn)
     │                       }
     │
     │                       func scanISBN(_ isbn: String) {
     │                           Task {
     │                               showLoading()
     │                               let book = try await scanBookUseCase.execute(isbn)
     │                               hideLoading()
     │                               coordinator?.didScanBook(book)
     │                           }
     │                       }
     ▼
ScanBookUseCase              func execute(_ isbn: String) async throws -> Book {
     │                           // 1. 로컬 캐시 확인
     │                           if let cached = try? await bookRepository.fetchLocal(isbn) {
     │                               return cached
     │                           }
     │                           // 2. API 호출
     │                           let book = try await bookRepository.fetchRemote(isbn)
     │                           // 3. 로컬에 저장
     │                           try await bookRepository.save(book)
     │                           return book
     │                       }
     ▼
BookRepository               func fetchRemote(_ isbn: String) async throws -> Book {
     │                           let dto = try await remoteDataSource.fetchBook(isbn)
     │                           return dto.toDomain()  // DTO → Entity 변환
     │                       }
     ▼
BookAPIService               func fetchBook(_ isbn: String) async throws -> BookDTO {
     │                           let url = Endpoint.book(isbn: isbn).url
     │                           let data = try await networkService.request(url)
     │                           return try JSONDecoder().decode(BookDTO.self, from: data)
     │                       }
     ▼
[API 응답 수신]
     │
     ▼
ScannerCoordinator           func didScanBook(_ book: Book) {
     │                           // 자식 Coordinator 종료
     │                           navigationController.popViewController(animated: true)
     │                           finish()
     │                           // 부모에게 결과 전달
     │                           delegate?.scanner(self, didScan: book)
     │                       }
     ▼
HomeCoordinator              func scanner(_ coordinator: ScannerCoordinator, didScan book: Book) {
     │                           childCoordinators.removeAll { $0 === coordinator }
     │                           showBookProfile(book: book)
     │                       }
     ▼
BookProfileCoordinator       func start() {
     │                           // SwiftUI 화면으로 이동
     │                           let view = BookProfileView(book: book)
     │                           pushSwiftUI(view)
     │                       }
     ▼
[책 정보 화면 표시]
```

---

## 📋 파일 네이밍 컨벤션

### 일반 규칙

| 타입 | 네이밍 | 예시 |
|-----|--------|------|
| Entity | 명사 단수 | `Book.swift`, `Room.swift` |
| Repository Protocol | ~RepositoryProtocol | `BookRepositoryProtocol` |
| Repository 구현체 | ~Repository | `BookRepository` |
| UseCase | 동사 + 명사 + UseCase | `ScanBookUseCase`, `LoadRoomsUseCase` |
| ViewController | 화면명 + ViewController | `HomeViewController` |
| ViewModel | 화면명 + ViewModel | `HomeViewModel` |
| Coordinator | 화면명 + Coordinator | `HomeCoordinator` |
| SwiftUI View | 화면명 + View | `BookProfileView` |
| DTO | 명사 + DTO | `BookDTO`, `RoomDTO` |
| Service | 기능명 + Service | `NetworkService`, `KeychainService` |
| Manager | 기능명 + Manager | `HomeKitManager`, `CoreDataManager` |

### 폴더 네이밍

```
Scenes/
├── Home/              # 화면 이름 (대문자 시작)
│   ├── HomeViewController.swift
│   ├── HomeViewModel.swift
│   └── SubViews/      # 서브뷰들
│       ├── RoomCell.swift
│       └── DeviceCard.swift
```

---

## ✅ 새 기능 추가 체크리스트

### 📱 새 화면 추가 시

- [ ] **Domain Layer**
  - [ ] Entity 필요하면 생성 (`Domain/Entities/`)
  - [ ] Repository Protocol 추가 (`Domain/Protocols/RepositoryProtocols.swift`)
  - [ ] UseCase 생성 (`Domain/UseCases/`)

- [ ] **Data Layer**
  - [ ] Repository 구현체 생성 (`Data/Repositories/`)
  - [ ] DTO 필요하면 생성 (`Data/DTOs/`)
  - [ ] DataSource 필요하면 생성 (`Data/DataSources/`)

- [ ] **Application Layer**
  - [ ] DIContainer에 Repository 등록
  - [ ] DIContainer에 UseCase 팩토리 메서드 추가

- [ ] **Presentation Layer**
  - [ ] ViewController 생성 (`Presentation/Scenes/화면명/`)
  - [ ] Coordinator 생성 (`Presentation/Coordinators/`)
  - [ ] 부모 Coordinator에서 호출 메서드 추가
  - [ ] SubViews 필요하면 생성

### 🔗 API 연동 시

- [ ] DTO 생성 (`Data/DTOs/`)
- [ ] Endpoint 정의 (`Infrastructure/Network/Endpoints.swift`)
- [ ] APIService 메서드 추가
- [ ] Repository에서 호출
- [ ] 에러 핸들링 추가

### 🏠 HomeKit 연동 시

- [ ] Info.plist에 권한 추가 (`NSHomeKitUsageDescription`)
- [ ] HomeKitManager에 메서드 추가
- [ ] DIContainer에 등록
- [ ] UseCase 생성
- [ ] UI 연결

---

## 🐛 디버깅 팁

### DI 관련 문제

```swift
// 문제: "어디서 주입이 안 됐지?"
// 해결: DIContainer에서 시작해서 추적

// 1. DIContainer 확인
print("DIContainer.shared.bookRepository: \(DIContainer.shared.bookRepository)")

// 2. Coordinator에서 UseCase 생성 확인
func start() {
    let useCase = diContainer.makeScanBookUseCase()
    print("UseCase created: \(useCase)")  // 디버깅
    ...
}

// 3. ViewController에서 주입 확인
init(useCase: ScanBookUseCase) {
    print("VC received useCase: \(useCase)")  // 디버깅
    self.useCase = useCase
    super.init(...)
}
```

### 화면 전환 문제

```swift
// 문제: "화면이 안 나와요"
// 확인 사항:

// 1. NavigationController가 제대로 전달됐는지
print("navigationController: \(navigationController)")
print("viewControllers count: \(navigationController.viewControllers.count)")

// 2. Coordinator.start()가 호출됐는지
func start() {
    print("ScannerCoordinator.start() called")  // 디버깅
    ...
}

// 3. childCoordinators에 추가됐는지
func showScanner() {
    let coordinator = ScannerCoordinator(...)
    childCoordinators.append(coordinator)
    print("childCoordinators: \(childCoordinators.count)")  // 디버깅
    coordinator.start()
}
```

---

## 📚 Quick Reference

### Observable 바인딩 (MVC)

```swift
// ViewController에서
let rooms: Observable<[Room]> = Observable([])

override func bind() {
    viewModel.rooms.bind { [weak self] rooms in
        self?.tableView.reloadData()
    }
}
```

### SwiftUI 화면으로 이동 (Coordinator에서)

```swift
func showBookProfile(book: Book) {
    let view = BookProfileView(book: book) { [weak self] action in
        switch action {
        case .startReading:
            self?.showReading(book: book)
        case .back:
            self?.navigationController.popViewController(animated: true)
        }
    }
    pushSwiftUI(view)
}
```

### async/await 패턴

```swift
// ViewController에서 데이터 로드
func loadData() {
    Task {
        showLoading()
        do {
            let data = try await useCase.execute()
            updateUI(with: data)
        } catch {
            showError(error.localizedDescription)
        }
        hideLoading()
    }
}
```

### Repository 패턴

```swift
// Protocol (Domain 레이어)
protocol BookRepositoryProtocol: Sendable {
    func fetch(isbn: String) async throws -> Book
    func save(_ book: Book) async throws
}

// 구현체 (Data 레이어)
final class BookRepository: BookRepositoryProtocol {
    private let remote: BookAPIService
    private let local: BookLocalDataSource

    func fetch(isbn: String) async throws -> Book {
        // 로컬 먼저 확인, 없으면 API
        if let cached = try? await local.fetch(isbn) {
            return cached
        }
        let dto = try await remote.fetch(isbn)
        let book = dto.toDomain()
        try await local.save(book)
        return book
    }
}
```

---

**이 문서를 보면서 코딩하면 "어디에 뭘 만들지" 고민 없이 진행할 수 있습니다!** 🚀
