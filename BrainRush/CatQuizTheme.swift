import SwiftUI

enum CatQuizPalette {
    static let ink = Color(red: 0.07, green: 0.16, blue: 0.23)
    static let cream = Color(red: 0.99, green: 0.94, blue: 0.84)
    static let wood = Color(red: 0.43, green: 0.29, blue: 0.18)
}

struct CatQuizHost: View {
    let isMistake: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(isMistake ? "QuizCatThinking" : "QuizCat")
                .resizable()
                .scaledToFit()
                .frame(width: 146, height: 106, alignment: .bottom)
                .accessibilityHidden(true)
            Text(isMistake
                 ? tr(ja: "もう一度、\nよ〜く見てね！", zh: "再来一次，\n仔细看哦！", en: "Look closely,\ntry again!", my: "သေချာကြည့်ပြီး\nထပ်ကြိုးစားပါ။")
                 : tr(ja: "よ〜く見て\n選んでね！", zh: "仔细看看，\n再选答案！", en: "Look closely\nand choose!", my: "သေချာကြည့်ပြီး\nရွေးပါ။"))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
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
