import SwiftUI

// 추후 데미안 ISBN에서 넘겨주는 Book모델로 변경 예정
struct BookProfileModel: Codable {
    let bookCoverImageURL: URL?
    let bookTitle: String
    let bookDescription: String

    static let mock = BookProfileModel(
        bookCoverImageURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780156012195-L.jpg"),
        bookTitle: "완다는 별의 소리를 들어요",
        bookDescription: "사막에 불시착한 비행사가 별에서 온 왕자를 만나 대화하며, 여우에게 길들여짐과 관계의 소중한 책임감을 배운 뒤에, 사랑하는 장미가 있는 자신의 별로 돌아가는 이야기입니다."
    )
}

struct BookProfileView: View {

    // MARK: - Properties

    let coordinator: AppCoordinator
    let book: BookProfileModel

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack {
                BookCoverSection(
                    bookCoverImageURL: book.bookCoverImageURL,
                    title: book.bookTitle,
                    plot: book.bookDescription,
                    height: geometry.size.height * 0.7
                )
                Spacer()
                PrimaryButtonSwiftUI(title: "책 환경 세팅하기") {
                    coordinator.showReading(book: book)
                }
                .padding(20)
            }
        }
    }
}

// MARK: - Subviews

private struct BookCoverSection: View {
    let bookCoverImageURL: URL?
    let title: String
    let plot: String
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            if let url = bookCoverImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                    case .failure, .empty:
                        Rectangle()
                            .fill(Color.gray)
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea(edges: .top)
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray)
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea(edges: .top)
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .ignoresSafeArea(edges: .top)
            }

            LinearGradient(
                colors: [.white, .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title2Emphasized)
                Text(plot)
                    .font(.bodyRegular)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        BookProfileView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            book: .mock
        )
    }
}
