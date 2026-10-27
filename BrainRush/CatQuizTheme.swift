import SwiftUI

enum QuizCatFace: String {
    case happy = "QuizCat"
    case thinking = "QuizCatThinking"
    case cheer = "QuizCatCheer"
    case sad = "QuizCatSad"
    case surprised = "QuizCatSurprised"
    case curious = "QuizCatCurious"
}

struct QuizCatPortrait: View {
    var face: QuizCatFace
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var alignment: Alignment = .center
    var companion: CatCompanion? = nil
    var accessibilityID = "quiz-cat"

    @State private var localCompanion = CatCompanion()

    var body: some View {
        let cat = companion ?? localCompanion
        let h = height ?? ((width ?? 96) * 0.75)
        let w = width ?? h * (4 / 3)
        let reaction = cat.sample(at: .now)
        Button { cat.pet() } label: {
            Image(face.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h, alignment: alignment)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .simultaneousGesture(DragGesture(minimumDistance: 12).onEnded { _ in cat.pet(stroked: true) })
        .accessibilityLabel(tr(ja: "ねこ", zh: "猫咪", en: "Your cat", my: "ကြောင်လေး", ko: "고양이", fr: "Ton chat"))
        .accessibilityValue(reaction.action.activityText ?? face.activityText)
        .accessibilityHint(tr(ja: "タップやなでる動きで遊べるよ。", zh: "轻点摸摸，或滑动抚摸猫咪。", en: "Tap or stroke your cat to interact.", my: "ကြောင်လေးကို နှိပ် သို့မဟုတ် ပွတ်ပေးပါ။", ko: "누르거나 쓸어 쓰다듬어 주세요.", fr: "Touche ou caresse ton chat."))
        .accessibilityIdentifier(accessibilityID)
    }
}

extension QuizCatFace {
    var mood: CatMood {
        switch self {
        case .happy: .content
        case .thinking: .thinking
        case .cheer: .delighted
        case .sad: .concerned
        case .surprised: .surprised
        case .curious: .curious
        }
    }

    var activityText: String {
        switch self {
        case .cheer: tr(ja: "喜んでいる", zh: "开心地陪着你", en: "Happy to be with you", my: "ပျော်ရွှင်နေသည်")
        case .sad: tr(ja: "応援している", zh: "陪你再试一次", en: "Here to encourage you", my: "အားပေးနေသည်")
        case .surprised: tr(ja: "びっくりしている", zh: "有点惊讶", en: "A little surprised", my: "အံ့သြနေသည်")
        case .thinking, .curious: tr(ja: "一緒に考えている", zh: "正在陪你思考", en: "Thinking with you", my: "အတူစဉ်းစားနေသည်")
        case .happy: tr(ja: "そばにいる", zh: "正在陪着你", en: "Keeping you company", my: "အဖော်ပြုပေးနေသည်")
        }
    }
}

extension CatAction {
    var activityText: String? {
        switch self {
        case .none: nil
        case .pet: tr(ja: "なでられて嬉しい", zh: "正在享受抚摸", en: "Enjoying a pet", my: "ပွတ်ပေးသည်ကို နှစ်သက်နေသည်", ko: "쓰다듬기를 즐기는 중", fr: "Il aime tes caresses")
        case .nuzzle: tr(ja: "すり寄っている", zh: "正在蹭手", en: "Nuzzling your hand", my: "လက်ကို ပွတ်နေသည်", ko: "손에 비비는 중", fr: "Il se frotte à ta main")
        case .roll: tr(ja: "お腹を見せている", zh: "正在翻身", en: "Rolling over", my: "လှိမ့်နေသည်", ko: "배를 보이며 구르는 중", fr: "Il se roule sur le dos")
        case .celebrate: tr(ja: "喜んでいる", zh: "正在庆祝", en: "Celebrating with you", my: "အတူပျော်ရွှင်နေသည်", ko: "함께 기뻐하는 중", fr: "Il fête ta réussite")
        case .encourage: tr(ja: "応援している", zh: "正在给你打气", en: "Encouraging you", my: "အားပေးနေသည်", ko: "응원하는 중", fr: "Il t'encourage")
        case .greet, .meow: tr(ja: "にゃあと挨拶している", zh: "正在喵喵打招呼", en: "Meowing hello", my: "ညောင်ဟု နှုတ်ဆက်နေသည်", ko: "야옹 인사하는 중", fr: "Il dit bonjour en miaulant")
        }
    }
}

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
    var companion: CatCompanion? = nil

    var body: some View {
        let message = hint ?? (isMistake
            ? tr(ja: "答えの理由を\n一緒に見よう！", zh: "一起看看，\n为什么选它！", en: "Let's see\nwhy this fits!", my: "အဖြေမှန်ရဲ့\nအကြောင်းရင်းကြည့်မယ်")
            : tr(ja: "よ〜く見て\n選んでね！", zh: "仔细看看，\n再选答案！", en: "Look closely\nand choose!", my: "သေချာကြည့်ပြီး\nရွေးပါ။"))
        HStack(alignment: .center, spacing: 0) {
            QuizCatPortrait(face: hostFace, width: 108, height: 84, alignment: .bottom,
                            companion: companion, accessibilityID: "stroop-host-cat")
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

    private var hostFace: QuizCatFace {
        if celebrating { return .cheer }
        if isMistake { return .sad }
        if hint != nil { return .curious }
        return .happy
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
