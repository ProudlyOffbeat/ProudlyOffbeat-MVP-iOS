import SwiftUI

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
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                }
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
        ZStack(alignment: .top) {
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
                .frame(height: height)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: height)
            }

            LinearGradient(
                colors: [.white, .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: height)

            VStack(alignment: .leading, spacing: 12) {
                Spacer()
                Text(title)
                    .font(.title2Emphasized)
                Text(plot)
                    .font(.bodyRegular)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}
