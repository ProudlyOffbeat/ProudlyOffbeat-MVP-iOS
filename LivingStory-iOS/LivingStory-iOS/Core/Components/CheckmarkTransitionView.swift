//
//  CheckmarkTransitionView.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ✅ 체크마크 그리기 전환 인터랙션
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  검은 전체화면에 그라데이션 체크가 펜으로 그려지듯 나타났다가, onFinished 호출.
//  독서 종료 등 "완료" 전환 연출에 재사용 가능.
//
//  ▸ 모양: Figma 내보낸 SVG(viewBox 96×77)의 fill path를 좌표 그대로 옮긴 닫힌 도형.
//  ▸ 연출: 정확한 도형을 그라데이션으로 채워두고, 중심선(spine)을 따라가는 굵은
//          stroke를 .trim 으로 키워 mask 로 덮음 → 왼팔→꼭짓점→우상단 끝 순서로
//          "펜으로 그려지듯" 정확한 픽셀이 드러난다.
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct CheckmarkTransitionView: View {

    /// 체크 등장 + 정지 후 호출 (다음 화면 전환 트리거)
    let onFinished: () -> Void

    /// 등장(스프링) 시간
    private let appearDuration: Double = 0.5
    /// 등장 후 정지(다음 화면 넘어가기 전)
    private let holdDuration: Double = 0.8

    @State private var reveal: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
            // 새 Check 에셋 — 왼쪽→오른쪽으로 그려지듯 드러남(체크되는 효과), 전체화면 중앙
            Image("Check")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .mask(alignment: .leading) {
                    GeometryReader { geo in
                        Rectangle().frame(width: geo.size.width * reveal)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)   // 전체화면 채워 화면 진짜 중앙에
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: appearDuration)) { reveal = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + appearDuration + holdDuration) {
                onFinished()
            }
        }
    }
}

// MARK: - Animated Checkmark (재사용)

/// 그라데이션 체크가 펜으로 그려지듯 나타나는 애니메이션 뷰.
/// 독서 종료 전환(CheckmarkTransitionView)과 온보딩 세팅 완료(SetupCompleteView)에서 공유.
struct AnimatedCheckmark: View {

    /// 체크 글리프 크기 (기본 = Figma 원본 96×77, 비율 유지 권장)
    var size: CGSize = CGSize(width: 96, height: 77)
    /// 그려지는 시간
    var drawDuration: Double = 0.7
    /// onAppear에서 자동 재생
    var autoPlay: Bool = true

    @State private var progress: CGFloat = 0

    /// 마스크 스트로크 두께(디자인 96 기준 28)를 크기에 맞춰 스케일
    private var maskLineWidth: CGFloat { 28 * (size.width / 96) }

    var body: some View {
        FigmaCheckShape()
            .fill(AnimatedCheckmark.gradient)
            .frame(width: size.width, height: size.height)
            // 중심선 따라가는 굵은 stroke를 trim으로 키워 도형을 점진적으로 드러냄(펜-드로잉)
            .mask(
                CheckSpine()
                    .trim(from: 0, to: progress)
                    .stroke(
                        style: StrokeStyle(lineWidth: maskLineWidth, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: size.width, height: size.height)
            )
            .onAppear {
                guard autoPlay else { return }
                withAnimation(.easeInOut(duration: drawDuration)) {
                    progress = 1
                }
            }
    }

    /// Figma 그라데이션(userSpaceOnUse) 복제: 우상단 파랑 → 중앙 연두 → 좌하단 노랑.
    static let gradient = LinearGradient(
        stops: [
            .init(color: Color(checkHex: 0x63B0FF), location: 0.159), // 파랑
            .init(color: Color(checkHex: 0xBFEE68), location: 0.421), // 연두
            .init(color: Color(checkHex: 0xFFCB24), location: 0.788)  // 노랑
        ],
        startPoint: UnitPoint(x: 95.0329 / 96, y: 65.712 / 77),
        endPoint: UnitPoint(x: -5.69032 / 96, y: 35.8199 / 77)
    )
}

// MARK: - Check Art (fill path · spine · 중앙정렬 변환 공용)

/// 체크 fill 도형과 마스크용 중심선(spine)을 담고, 둘 다 "글리프 실제 경계 기준" 동일 변환으로
/// rect 중앙에 정렬한다. → 어떤 frame에서도 가로·세로 정중앙, fill·spine은 정확히 겹침.
private enum CheckArt {
    static let design = CGSize(width: 96, height: 77)

    /// 체크 글리프의 실제(on-path) 바운딩. Figma 절대좌표는 96×77 박스 안에서 위로 치우쳐 있어
    /// 단순 스케일만 하면 세로 중앙이 어긋난다. 이 값을 기준으로 중앙 정렬한다.
    static let glyphBounds = CGRect(x: 0.730162, y: 0, width: 93.8675, height: 72.7969)

    /// Figma SVG(viewBox 96×77)의 `<path d>` 를 좌표 그대로 옮긴 닫힌 도형.
    static let fillPath: Path = {
        var p = Path()
        p.move(to: CGPoint(x: 70.8669, y: 4.87691))
        p.addCurve(to: CGPoint(x: 84.3203, y: 0), control1: CGPoint(x: 75.5844, y: 1.59526), control2: CGPoint(x: 80, y: -7.08923e-06))
        p.addCurve(to: CGPoint(x: 88.7109, y: 0.670899), control1: CGPoint(x: 86.1067, y: 0.109987), control2: CGPoint(x: 87.6235, y: 0.402059))
        p.addCurve(to: CGPoint(x: 90.0498, y: 1.04688), control1: CGPoint(x: 89.2591, y: 0.80642), control2: CGPoint(x: 89.7118, y: 0.939318))
        p.addCurve(to: CGPoint(x: 90.4727, y: 1.1875), control1: CGPoint(x: 90.2188, y: 1.10066), control2: CGPoint(x: 90.3608, y: 1.14839))
        p.addCurve(to: CGPoint(x: 90.6191, y: 1.24023), control1: CGPoint(x: 90.5285, y: 1.20705), control2: CGPoint(x: 90.5782, y: 1.2253))
        p.addCurve(to: CGPoint(x: 90.6748, y: 1.26074), control1: CGPoint(x: 90.6394, y: 1.24761), control2: CGPoint(x: 90.6583, y: 1.25461))
        p.addCurve(to: CGPoint(x: 90.6982, y: 1.26953), control1: CGPoint(x: 90.6829, y: 1.26377), control2: CGPoint(x: 90.691, y: 1.26682))
        p.addCurve(to: CGPoint(x: 90.709, y: 1.27344), control1: CGPoint(x: 90.7018, y: 1.27086), control2: CGPoint(x: 90.7057, y: 1.27219))
        p.addLine(to: CGPoint(x: 90.7139, y: 1.27539))
        p.addCurve(to: CGPoint(x: 88.5098, y: 7.10547), control1: CGPoint(x: 90.7145, y: 1.2807), control2: CGPoint(x: 90.6568, y: 1.44005))
        p.addLine(to: CGPoint(x: 90.7188, y: 1.27734))
        p.addCurve(to: CGPoint(x: 94.5977, y: 9.89063), control1: CGPoint(x: 94.1683, y: 2.5849), control2: CGPoint(x: 95.905, y: 6.44094))
        p.addCurve(to: CGPoint(x: 85.9932, y: 13.7734), control1: CGPoint(x: 93.2914, y: 13.3373), control2: CGPoint(x: 89.4406, y: 15.0743))
        p.addCurve(to: CGPoint(x: 86.002, y: 13.7774), control1: CGPoint(x: 85.996, y: 13.7746), control2: CGPoint(x: 85.9993, y: 13.7763))
        p.addCurve(to: CGPoint(x: 86.0176, y: 13.7822), control1: CGPoint(x: 86.0073, y: 13.7793), control2: CGPoint(x: 86.013, y: 13.7805))
        p.addCurve(to: CGPoint(x: 86.042, y: 13.792), control1: CGPoint(x: 86.027, y: 13.7858), control2: CGPoint(x: 86.0356, y: 13.7897))
        p.addLine(to: CGPoint(x: 85.998, y: 13.7774))
        p.addCurve(to: CGPoint(x: 85.5049, y: 13.6406), control1: CGPoint(x: 85.9105, y: 13.7495), control2: CGPoint(x: 85.7407, y: 13.699))
        p.addCurve(to: CGPoint(x: 83.5, y: 13.335), control1: CGPoint(x: 85.0232, y: 13.5216), control2: CGPoint(x: 84.3186, y: 13.3854))
        p.addCurve(to: CGPoint(x: 78.4958, y: 15.8437), control1: CGPoint(x: 81.8166, y: 13.2313), control2: CGPoint(x: 79.9348, y: 14.8428))
        p.addCurve(to: CGPoint(x: 70.5876, y: 24.8281), control1: CGPoint(x: 77.0389, y: 16.8572), control2: CGPoint(x: 74.3117, y: 19.8217))
        p.addCurve(to: CGPoint(x: 59.2097, y: 41.6338), control1: CGPoint(x: 67.0514, y: 29.5819), control2: CGPoint(x: 63.1061, y: 35.4913))
        p.addCurve(to: CGPoint(x: 40.8552, y: 72.4101), control1: CGPoint(x: 51.4258, y: 53.9044), control2: CGPoint(x: 44.0477, y: 66.7648))
        p.addCurve(to: CGPoint(x: 25.9352, y: 72.7969), control1: CGPoint(x: 37.5487, y: 78.2571), control2: CGPoint(x: 29.3925, y: 78.1929))
        p.addCurve(to: CGPoint(x: 15.8386, y: 58.2715), control1: CGPoint(x: 23.7166, y: 69.3337), control2: CGPoint(x: 19.7922, y: 63.3936))
        p.addCurve(to: CGPoint(x: 10.3942, y: 51.9307), control1: CGPoint(x: 13.8495, y: 55.6946), control2: CGPoint(x: 11.9746, y: 53.484))
        p.addCurve(to: CGPoint(x: 0.730162, y: 47.3945), control1: CGPoint(x: 7.67969, y: 48.8603), control2: CGPoint(x: 3.17969, y: 50.3603))
        p.addCurve(to: CGPoint(x: 3.64716, y: 38.4092), control1: CGPoint(x: -0.945403, y: 44.1079), control2: CGPoint(x: 0.360611, y: 40.085))
        p.addCurve(to: CGPoint(x: 6.96259, y: 37.2099), control1: CGPoint(x: 4.11858, y: 38.1688), control2: CGPoint(x: 5.35525, y: 37.499))
        p.addCurve(to: CGPoint(x: 11.197, y: 37.2588), control1: CGPoint(x: 8.55566, y: 36.9236), control2: CGPoint(x: 10.0199, y: 37.0777))
        p.addCurve(to: CGPoint(x: 16.197, y: 39.3906), control1: CGPoint(x: 13.3072, y: 37.5835), control2: CGPoint(x: 15.0441, y: 38.5957))
        p.addCurve(to: CGPoint(x: 19.7595, y: 42.4023), control1: CGPoint(x: 17.4527, y: 40.2565), control2: CGPoint(x: 18.6568, y: 41.3186))
        p.addCurve(to: CGPoint(x: 26.4147, y: 50.1074), control1: CGPoint(x: 21.9698, y: 44.5748), control2: CGPoint(x: 24.2711, y: 47.3302))
        p.addCurve(to: CGPoint(x: 32.9938, y: 59.2471), control1: CGPoint(x: 28.7407, y: 53.1208), control2: CGPoint(x: 31.0236, y: 56.352))
        p.addCurve(to: CGPoint(x: 47.9284, y: 34.4775), control1: CGPoint(x: 36.8227, y: 52.6216), control2: CGPoint(x: 42.2596, y: 43.4139))
        p.addCurve(to: CGPoint(x: 59.8679, y: 16.8535), control1: CGPoint(x: 51.9055, y: 28.2079), control2: CGPoint(x: 56.0499, y: 21.986))
        p.addCurve(to: CGPoint(x: 70.8669, y: 4.87691), control1: CGPoint(x: 63.4978, y: 11.9737), control2: CGPoint(x: 67.3894, y: 7.29604))
        p.closeSubpath()
        return p
    }()

    /// 체크의 중심선(왼팔 끝 → 꼭짓점 → 우상단 끝). fill과 동일 변환으로 정확히 겹친다.
    static let spinePath: Path = {
        var p = Path()
        p.move(to: CGPoint(x: 5, y: 42))                       // 왼팔 끝
        p.addLine(to: CGPoint(x: 30, y: 66))                   // 꼭짓점(꺾이는 곳)
        p.addQuadCurve(                                        // 우상단으로 부드럽게 휘는 긴 팔
            to: CGPoint(x: 87, y: 7),
            control: CGPoint(x: 58, y: 40)
        )
        return p
    }()

    /// 글리프 실제 경계 중심을 rect 중심에 맞춰 스케일·정렬. fill·spine 모두 같은 변환을 쓴다.
    static func aligned(_ path: Path, in rect: CGRect) -> Path {
        let scale = min(rect.width / design.width, rect.height / design.height)
        var t = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        t = t.scaledBy(x: scale, y: scale)
        t = t.translatedBy(x: -glyphBounds.midX, y: -glyphBounds.midY)
        return path.applying(t)
    }
}

private struct FigmaCheckShape: Shape {
    func path(in rect: CGRect) -> Path { CheckArt.aligned(CheckArt.fillPath, in: rect) }
}

private struct CheckSpine: Shape {
    func path(in rect: CGRect) -> Path { CheckArt.aligned(CheckArt.spinePath, in: rect) }
}

// MARK: - Color Helper

private extension Color {
    init(checkHex hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    CheckmarkTransitionView(onFinished: {})
}
