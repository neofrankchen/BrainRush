import SwiftUI

enum CatQuizPalette {
    static let ink = Color(red: 0.07, green: 0.16, blue: 0.23)
    static let cream = Color(red: 0.99, green: 0.94, blue: 0.84)
    static let wood = Color(red: 0.43, green: 0.29, blue: 0.18)
}

struct WoodlandIconBadge: View {
    var symbol: String
    var rotation: Double = 0
    var lit = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(CatQuizPalette.wood)
            .rotationEffect(.degrees(rotation))
            .frame(width: 48, height: 48)
            .background {
                Circle().fill(
                    LinearGradient(
                        colors: lit
                            ? [Color(red: 1, green: 0.93, blue: 0.46), Color(red: 1, green: 0.72, blue: 0.24)]
                            : [Color(red: 1, green: 0.97, blue: 0.88), Color(red: 0.98, green: 0.89, blue: 0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .overlay {
                Circle().strokeBorder(Color(red: 0.67, green: 0.40, blue: 0.20).opacity(0.85), lineWidth: 1.6)
            }
            .overlay {
                Circle()
                    .strokeBorder(Color(red: 1, green: 0.99, blue: 0.92).opacity(0.9), lineWidth: 1.2)
                    .padding(3.5)
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.42))
                    .frame(width: 20, height: 6)
                    .padding(.top, 8)
            }
            .shadow(color: CatQuizPalette.wood.opacity(0.22), radius: 8, y: 4)
    }
}

struct CatQuizHost: View {
    var isMistake = false
    var hint: String? = nil
    var celebrating = false

    var body: some View {
        let message = hint ?? (isMistake
            ? tr(ja: "答えの理由を\n一緒に見よう！", zh: "一起看看，\n为什么选它！", en: "Let's see\nwhy this fits!", my: "အဖြေမှန်ရဲ့\nအကြောင်းရင်းကြည့်မယ်")
            : tr(ja: "よ〜く見て\n選んでね！", zh: "仔细看看，\n再选答案！", en: "Look closely\nand choose!", my: "သေချာကြည့်ပြီး\nရွေးပါ။"))
        HStack(alignment: .center, spacing: 0) {
            Image(celebrating || (hint == nil && !isMistake) ? "QuizCat" : "QuizCatThinking")
                .resizable()
                .scaledToFit()
                .frame(width: 146, height: 106, alignment: .bottom)
                .accessibilityHidden(true)
            Text(message)
                .font(.system(size: hint == nil ? 18 : 15, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(CatQuizPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background {
                    CatSpeechBubble()
                        .fill(CatQuizPalette.cream)
                        .shadow(color: CatQuizPalette.wood.opacity(0.15), radius: 0, y: 3)
                }
                .overlay(CatSpeechBubble().stroke(CatQuizPalette.wood, lineWidth: 2))
                .padding(.bottom, 20)
                .accessibilityIdentifier("stroop-cat-hint")
                .accessibilityLabel(message)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CatSpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(26, rect.height / 2)
        var path = Path()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: radius), control: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: -9, y: rect.maxY + 5), control: CGPoint(x: 8, y: rect.maxY + 10))
        path.addQuadCurve(to: CGPoint(x: 4, y: rect.maxY - 14), control: CGPoint(x: 2, y: rect.maxY - 3))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - radius), control: CGPoint(x: 0, y: rect.maxY - 20))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(to: CGPoint(x: radius, y: 0), control: .zero)
        path.closeSubpath()
        return path
    }
}
