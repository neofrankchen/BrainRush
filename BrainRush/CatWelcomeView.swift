import SwiftUI
import UIKit

/// The room, its cat, and the invitation that reveals the existing game menu.
@MainActor
struct CatWelcomeView<Controls: View>: View {
    @Binding var isMenuVisible: Bool
    var companion: CatCompanion
    var justPlayed = false
    var pauseIdle = false
    var idleNudge = 0
    @ViewBuilder var controls: () -> Controls

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var phase: Phase
    @State private var sequence: Task<Void, Never>?
    @State private var idleReturn: Task<Void, Never>?
    @State private var askedAgain = false
    @State private var journeyStart = Date.now
    @State private var journeyFrom: CGFloat
    @State private var journeyTo: CGFloat
    @State private var journeyDuration: TimeInterval = 0
    @State private var facingStart = Date.now
    @State private var facingFrom: CGFloat = 0
    @State private var facingTo: CGFloat = 0
    @State private var facingDuration: TimeInterval = 0
    @State private var settlingStart = Date.now
    @State private var recalledCurl: CGFloat = 0
    @State private var wakingStarted = Date.now

    private enum Phase {
        case sleeping, waking, approaching, greeting, welcomed, goodbye
        case turningAway, returning, turningToward, settling
    }

    init(
        isMenuVisible: Binding<Bool>,
        companion: CatCompanion,
        justPlayed: Bool = false,
        pauseIdle: Bool = false,
        idleNudge: Int = 0,
        @ViewBuilder controls: @escaping () -> Controls
    ) {
        _isMenuVisible = isMenuVisible
        self.companion = companion
        self.justPlayed = justPlayed
        self.pauseIdle = pauseIdle
        self.idleNudge = idleNudge
        self.controls = controls
        _phase = State(initialValue: isMenuVisible.wrappedValue ? .welcomed : .sleeping)
        _journeyFrom = State(initialValue: isMenuVisible.wrappedValue ? 1 : 0)
        _journeyTo = State(initialValue: isMenuVisible.wrappedValue ? 1 : 0)
    }

    var body: some View {
        let _ = LanguageStore.shared.language
        GeometryReader { geometry in
            let size = geometry.size
            let landscape = size.width > size.height * 1.15
            ZStack {
                cushion(in: size, landscape: landscape)
                cat(in: size, landscape: landscape)

                if showsDialogue || isMenuVisible {
                    dialogueAndMenu(in: size, landscape: landscape)
                        .transition(.opacity.combined(with: .offset(y: reduceMotion ? 0 : 12)))
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
        .onAppear { resetToRestingState() }
        .onDisappear {
            cancelIdleReturn()
            stopSequence()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                resetToRestingState()
            } else if newPhase == .active, phase == .greeting || phase == .welcomed {
                watchForIdleReturn()
            }
        }
        .onChange(of: isMenuVisible) { _, visible in
            if visible && phase != .welcomed {
                stopSequence()
                finishJourney(at: 1)
                finishFacing(at: 0)
                phase = .welcomed
            }
        }
        .onChange(of: pauseIdle) { _, paused in
            if paused {
                cancelIdleReturn()
            } else if phase == .greeting || phase == .welcomed {
                watchForIdleReturn()
            }
        }
        .onChange(of: idleNudge) { _, _ in
            if phase == .greeting || phase == .welcomed {
                watchForIdleReturn()
            }
        }
    }

    private var showsDialogue: Bool {
        phase == .greeting || phase == .goodbye || phase == .welcomed
    }

    private func cushion(in size: CGSize, landscape: Bool) -> some View {
        let width = restingWidth(in: size, landscape: landscape) * 1.66
        let height = width * (928.0 / 1695.0)
        let baseline = restingBaseline(in: size, landscape: landscape)
        return ZStack {
            Ellipse()
                .fill(Color(red: 0.31, green: 0.23, blue: 0.16).opacity(0.16))
                .frame(width: width * 0.86, height: width * 0.13)
                .blur(radius: width * 0.025)
                .position(x: size.width * 0.61 - width * 0.035, y: baseline + 2)
            Image("CozyCatCushion")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .position(x: size.width * 0.61, y: baseline - height * 0.3621)
        }
        .accessibilityHidden(true)
    }

    private func cat(in size: CGSize, landscape: Bool) -> some View {
        TimelineView(.animation(minimumInterval: catFrameInterval, paused: scenePhase != .active)) { context in
            let progress = journeyProgress(at: context.date)
            let restWidth = restingWidth(in: size, landscape: landscape)
            let foregroundWidth = foregroundWidth(in: size, landscape: landscape)
            let curl = catCurl(at: context.date)
            let width = restWidth + (foregroundWidth - restWidth) * progress
            // Sleeping art sits higher in the square than standing poses, so drop it onto the cushion.
            let restY = restingBaseline(in: size, landscape: landscape) - restWidth * 0.26 + curl * restWidth * 0.07
            let frontY = foregroundBaseline(in: size, landscape: landscape)
            let frontX = size.width * (landscape ? 0.27 : 0.5)
            let x = size.width * 0.61 + (frontX - size.width * 0.61) * progress
            let baseline = restY + (frontY - restY) * progress
            let walking = phase == .approaching || phase == .returning
            let reaction = companion.sample(at: context.date)
            let stepRate = walkStepRate()
            let bob: CGFloat = (walking && !reduceMotion)
                ? CGFloat(sin(context.date.timeIntervalSince(journeyStart) * stepRate * .pi)) * width * 0.012
                : 0

            ZStack {
                contactShadow(width: width, sleeping: phase == .sleeping, at: context.date)
                    .position(x: x, y: baseline)

                Button(action: catTapped) {
                    cozyCatSprite(at: context.date, walking: walking, reaction: reaction)
                        .transaction { $0.animation = nil }
                        .frame(width: width, height: width)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)
                .position(x: x, y: baseline - width * 0.40 + bob)
                .simultaneousGesture(DragGesture(minimumDistance: 12).onEnded { _ in
                    if phase == .greeting || phase == .welcomed {
                        companion.pet(stroked: true)
                        watchForIdleReturn()
                    }
                })
                .accessibilityLabel(catLabel)
                .accessibilityValue((phase == .greeting || phase == .welcomed)
                                    ? reaction.action.activityText ?? catState : catState)
                .accessibilityHint(catHint)
                .accessibilityIdentifier("home-cat")
                .accessibilitySortPriority(phase == .sleeping ? 1 : 0)

                if phase == .sleeping {
                    sleepingMarks(at: context.date)
                        .position(x: x + width * 0.32, y: baseline - width * 0.66)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    private func cozyCatSprite(at date: Date, walking: Bool, reaction: CatActionSample) -> some View {
        let facing = facingProgress(at: date)
        let curl = catCurl(at: date)
        let pose = reaction.gesture
        let moving = pose.pet + pose.nuzzle + pose.roll + pose.cheer > 0.01
        let breath = sleepBreath(at: date, curl: curl)
        return Image(cozyCatName(facing: facing, walking: walking, curl: curl, at: date))
            .resizable()
            .scaledToFit()
            .scaleEffect(
                x: 1 + breath * 0.015 + (moving ? pose.cheer * 0.04 + pose.pet * 0.015 : 0),
                y: 1 + breath * 0.04 + (moving ? pose.cheer * 0.04 + pose.pet * 0.015 : 0),
                anchor: curl > 0.4 ? UnitPoint(x: 0.51, y: 0.81) : .bottom
            )
            .rotationEffect(.degrees(moving ? Double(pose.nuzzle * 4 - pose.pet * 2.5 + pose.roll * 8) : 0))
            .offset(y: moving ? pose.roll * -8 - pose.cheer * 5 : 0)
    }

    private func cozyCatName(facing: CGFloat, walking: Bool, curl: CGFloat, at date: Date) -> String {
        if curl > 0.55 { return "CozyCatSleeping" }
        let step = !reduceMotion && Int(date.timeIntervalSince(journeyStart) * walkStepRate()) % 2 == 1
        if walking || facing > 0.22 {
            if facing > 0.68 {
                return step && walking ? "CozyCatWalkingAwayAlternate" : "CozyCatWalkingAway"
            }
            if facing > 0.22 {
                return step && walking ? "CozyCatTurningAlternate" : "CozyCatTurning"
            }
            return step ? "CozyCatWalkingAlternate" : "CozyCatWalking"
        }
        return "CozyCatSitting"
    }

    private func contactShadow(width: CGFloat, sleeping: Bool, at date: Date) -> some View {
        let breath = sleeping ? sleepBreath(at: date, curl: 1) : 0
        return ZStack {
            Ellipse()
                .fill(Color(red: 0.32, green: 0.23, blue: 0.16).opacity(sleeping ? 0.10 : 0.15))
                .frame(width: width * (sleeping ? 0.76 : 0.62), height: width * 0.09)
                .blur(radius: width * 0.025)
                .offset(x: sleeping ? -width * 0.02 : -width * 0.07, y: width * 0.012)
            Ellipse()
                .fill(Color(red: 0.29, green: 0.21, blue: 0.14).opacity(0.17))
                .frame(width: width * (sleeping ? 0.64 : 0.40), height: max(3, width * 0.025))
                .blur(radius: max(1, width * 0.007))
        }
        .scaleEffect(1 + (1 - breath) * (sleeping ? 0.06 : 0), anchor: .center)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var catFrameInterval: Double {
        if reduceMotion { return 0.12 }
        switch phase {
        case .approaching, .returning, .turningAway, .turningToward, .waking:
            return 1.0 / 12
        case .sleeping, .settling:
            return 1.0 / 10
        default:
            return 1.0 / 6
        }
    }

    private func sleepBreath(at date: Date, curl: CGFloat) -> CGFloat {
        guard !reduceMotion, curl > 0.4 else { return 0 }
        let inhale: TimeInterval = 1.4
        let exhale: TimeInterval = 2.3
        let rest: TimeInterval = 0.5
        let cycle = inhale + exhale + rest
        let t = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle)
        let amount: Double
        if t < inhale {
            let u = t / inhale
            amount = u * u * (3 - 2 * u)
        } else if t < inhale + exhale {
            let u = (t - inhale) / exhale
            let s = u * u * (3 - 2 * u)
            amount = 1 - s
        } else {
            amount = 0
        }
        return curl * CGFloat(amount)
    }

    private func catCurl(at date: Date) -> CGFloat {
        switch phase {
        case .sleeping: return 1
        case .waking:
            let t = min(1, max(0, date.timeIntervalSince(wakingStarted) / (reduceMotion ? 0.10 : 0.28)))
            return 1 - CGFloat(t * t * (3 - 2 * t))
        case .settling: return settlingProgress(at: date)
        case .turningToward: return recalledCurl * (1 - facingFraction(at: date))
        default: return 0
        }
    }

    private func walkingBlend(at date: Date) -> CGFloat {
        let elapsed = max(0, date.timeIntervalSince(journeyStart))
        let enter = min(1, elapsed / 0.18)
        let leave = min(1, max(0, journeyDuration - elapsed) / 0.18)
        let amount = CGFloat(min(enter, leave))
        return amount * amount * (3 - 2 * amount)
    }

    private func sleepingMarks(at date: Date) -> some View {
        HStack(alignment: .bottom, spacing: 2) {
            snoreZ("z", size: 12, at: date, delay: 0, rise: 14)
            snoreZ("z", size: 16, at: date, delay: 1.35, rise: 20)
            snoreZ("z", size: 21, at: date, delay: 2.7, rise: 26)
        }
        .foregroundStyle(CatQuizPalette.wood.opacity(0.48))
    }

    private func snoreZ(_ text: String, size: CGFloat, at date: Date, delay: TimeInterval, rise: CGFloat) -> some View {
        let period: TimeInterval = 4.1
        let t = reduceMotion
            ? 0.4
            : (date.timeIntervalSinceReferenceDate - delay).truncatingRemainder(dividingBy: period) / period
        let u = CGFloat(t)
        let fade = 4 * u * (1 - u)
        return Text(text)
            .font(.system(size: size, weight: .medium, design: .rounded))
            .offset(x: reduceMotion ? 0 : u * 5, y: reduceMotion ? 0 : -u * rise)
            .opacity(reduceMotion ? 0.7 : 0.18 + 0.62 * fade)
    }

    @ViewBuilder
    private func dialogueAndMenu(in size: CGSize, landscape: Bool) -> some View {
        if landscape {
            ScrollView {
                VStack(spacing: 18) {
                    if showsDialogue { dialogue }
                    if isMenuVisible { menuControls }
                }
                .padding(.horizontal, 12)
                .padding(.top, isMenuVisible ? 60 : 16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .frame(width: size.width * 0.48, height: size.height * 0.94)
            .position(x: size.width * 0.73, y: size.height * 0.5)
        } else {
            VStack(spacing: 0) {
                ScrollView {
                    dialogue
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 14)
                        .frame(minHeight: size.height * 0.40, alignment: .bottom)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .frame(height: size.height * 0.40)

                Spacer(minLength: 0)

                if isMenuVisible {
                    ScrollView {
                        menuControls
                            .padding(.horizontal, max(22, size.width * 0.065))
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .frame(maxWidth: 470)
                            .frame(maxWidth: .infinity)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(height: size.height * 0.25)
                    .transition(.opacity.combined(with: .offset(y: reduceMotion ? 0 : 18)))
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    private var menuControls: some View {
        controls()
            .simultaneousGesture(TapGesture().onEnded { watchForIdleReturn() })
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 28)
                    .fill(CatQuizPalette.cream.opacity(0.88))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1.5)
                    }
                    .shadow(color: CatQuizPalette.wood.opacity(0.14), radius: 14, y: 6)
            }
    }

    private var dialogue: some View {
        VStack(spacing: 20) {
            Text(dialogueText)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(CatQuizPalette.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 22)
                .padding(.vertical, 17)
                .frame(maxWidth: 430)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(CatQuizPalette.cream.opacity(0.97))
                        .shadow(color: CatQuizPalette.wood.opacity(0.16), radius: 10, y: 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(CatQuizPalette.wood.opacity(0.23), lineWidth: 1.4)
                        }
                }
                .overlay(alignment: .bottom) {
                    HomeCatBubbleTail()
                        .fill(CatQuizPalette.cream)
                        .frame(width: 20, height: 11)
                        .offset(y: 10)
                }
                .accessibilityIdentifier("home-cat-speech")
                .accessibilityAddTraits(.updatesFrequently)

            if phase == .greeting {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) { responseButtons }
                    VStack(spacing: 10) { responseButtons }
                }
                .frame(maxWidth: 390)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var responseButtons: some View {
        Group {
            Button(action: acceptInvitation) {
                Text(tr(ja: "いいよ", zh: "好啊", en: "Sure", my: "ကောင်းပြီ"))
                    .font(.system(.headline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
                    .frame(minWidth: 108, minHeight: 48)
                    .foregroundStyle(CatQuizPalette.ink)
                    .background(Color(red: 1, green: 0.79, blue: 0.35), in: Capsule())
                    .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.25), lineWidth: 1) }
            }
            .accessibilityIdentifier("home-accept")

            Button(action: declineInvitation) {
                Text(tr(ja: "またあとで", zh: "待会再说", en: "Later", my: "နောက်မှ"))
                    .font(.system(.headline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
                    .frame(minWidth: 108, minHeight: 48)
                    .foregroundStyle(CatQuizPalette.wood)
                    .background(CatQuizPalette.cream.opacity(0.96), in: Capsule())
                    .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.25), lineWidth: 1) }
            }
            .accessibilityIdentifier("home-decline")
        }
        .buttonStyle(.plain)
    }

    private var dialogueText: String {
        switch phase {
        case .goodbye:
            justPlayed
                ? tr(ja: "今日はおつかれさま。また遊ぼうね。", zh: "今天辛苦啦。想玩再叫我。", en: "Nice playing today. Call me when you want another round.", my: "ဒီနေ့ ကစားပြီးပြီ။ ကစားချင်ရင် ခေါ်ပါ။")
                : tr(ja: "うん、遊びたくなったら呼んでね。", zh: "嗯，想玩的时候再叫我。", en: "Call me when you want to play.", my: "ကစားချင်ရင် ခေါ်ပါ။")
        case .welcomed:
            justPlayed
                ? tr(ja: "おつかれさま！もう一回やる？", zh: "辛苦啦！还要再来一局吗？", en: "Nice round! Play again?", my: "ကစားပြီးပြီ။ နောက်တစ်ပွဲ လုပ်မလား။")
                : tr(ja: "やった、一緒に遊ぼう！", zh: "太好了，一起玩吧！", en: "Yay, let's play!", my: "ယေ့၊ အတူ ကစားကြမယ်။")
        default:
            justPlayed
                ? (askedAgain
                   ? tr(ja: "ねえ、もう一回やろうよ。", zh: "再来一局嘛，一起玩。", en: "Come on, one more round.", my: "နောက်တစ်ပွဲ အတူ ကစားကြမယ်။")
                   : tr(ja: "おかえり。また遊ぼう？", zh: "回来啦。再玩一次？", en: "Welcome back. Play again?", my: "ပြန်လာပြီ။ နောက်တစ်ပွဲ ကစားမလား။"))
                : (askedAgain
                   ? tr(ja: "ねえ、遊ばないの？一緒にやろうよ。", zh: "不一起玩吗？来嘛。", en: "You're not playing? Come on, let's go.", my: "မကစားဘူးလား။ အတူ ကစားကြမယ်။")
                   : tr(ja: "来てくれたんだ。一緒に遊ばない？", zh: "你来啦。一起玩吗？", en: "You came! Want to play together?", my: "လာပြီ။ အတူ ကစားမလား။"))
        }
    }

    private var catLabel: String {
        if phase == .greeting || phase == .welcomed {
            return tr(ja: "ねこをなでる", zh: "摸摸猫咪", en: "Pet your cat", my: "ကြောင်လေးကို ပွတ်ပေးရန်", ko: "고양이 쓰다듬기", fr: "Caresser ton chat")
        }
        return tr(ja: "ねこを起こす", zh: "叫醒猫咪", en: "Wake the cat", my: "ကြောင်လေးကို နှိုးရန်", ko: "고양이 깨우기", fr: "Réveiller le chat")
    }

    private var catState: String {
        switch phase {
        case .sleeping: tr(ja: "眠っている", zh: "睡觉中", en: "Sleeping", my: "အိပ်နေသည်", ko: "자는 중", fr: "Endormi")
        case .waking, .approaching: tr(ja: "こちらへ歩いている", zh: "正在走过来", en: "Coming to greet you", my: "နှုတ်ဆက်ရန် လာနေသည်", ko: "다가오는 중", fr: "Il vient te saluer")
        case .goodbye: tr(ja: "またねと挨拶している", zh: "正在道别", en: "Saying goodbye", my: "နှုတ်ဆက်နေသည်", ko: "작별 인사 중", fr: "Il dit au revoir")
        case .turningAway: tr(ja: "向きを変えている", zh: "正在转身", en: "Turning away", my: "နောက်ဘက်သို့ လှည့်နေသည်", ko: "뒤로 도는 중", fr: "Il se retourne")
        case .returning: tr(ja: "クッションへ戻っている", zh: "正在回软垫", en: "Returning to the cushion", my: "အခင်းဆီ ပြန်နေသည်", ko: "방석으로 돌아가는 중", fr: "Il retourne sur son coussin")
        case .turningToward: tr(ja: "こちらへ向き直っている", zh: "正在转过来", en: "Turning back toward you", my: "သင့်ဘက်သို့ ပြန်လှည့်နေသည်", ko: "다시 이쪽으로 도는 중", fr: "Il se tourne vers toi")
        case .settling: tr(ja: "横になっている", zh: "正在躺下", en: "Curling up to rest", my: "လှဲအိပ်နေသည်", ko: "몸을 웅크리는 중", fr: "Il se couche")
        case .greeting, .welcomed: tr(ja: "一緒に遊びたい", zh: "想和你一起玩", en: "Ready to play with you", my: "အတူ ကစားရန် အသင့်ဖြစ်သည်", ko: "같이 놀 준비 완료", fr: "Prêt à jouer avec toi")
        }
    }

    private var catHint: String {
        if phase == .greeting || phase == .welcomed {
            return tr(ja: "タップやなでる動きで遊べるよ。", zh: "轻点或滑动抚摸，猫咪会蹭手、翻身回应你。", en: "Tap or stroke your cat to see it nuzzle and roll over.", my: "ကြောင်လေးကို နှိပ် သို့မဟုတ် ပွတ်ပေးပါ။", ko: "누르거나 쓸어 쓰다듬어 주세요.", fr: "Touche ou caresse ton chat pour le voir se frotter et se rouler.")
        }
        if phase == .turningToward {
            return tr(ja: "こちらへ向き直ったら、また近づいてくるよ。", zh: "等猫咪转过来，它就会走向你。", en: "The cat will come over after turning toward you.", my: "သင့်ဘက် လှည့်ပြီးလျှင် ကြောင်လေး ပြန်လာမည်။", ko: "이쪽으로 돌아서면 다시 다가와요.", fr: "Il viendra vers toi après s'être retourné.")
        }
        if phase == .waking || phase == .approaching {
            return tr(ja: "もう一度タップすると、すぐに挨拶するよ。", zh: "再点一下，直接听猫咪打招呼。", en: "Tap again to skip ahead to the greeting.", my: "နှုတ်ဆက်ရန် ထပ်နှိပ်ပါ။", ko: "한 번 더 누르면 바로 인사해요.", fr: "Touche encore pour passer à son bonjour.")
        }
        return tr(ja: "タップして、一緒に遊ぼうと誘ってみよう。", zh: "点一下，叫猫咪过来一起玩。", en: "Tap to invite the cat over to play.", my: "အတူကစားရန် ကြောင်လေးကို နှိပ်ခေါ်ပါ။", ko: "눌러서 고양이를 놀자고 불러 보세요.", fr: "Touche le chat pour l'inviter à jouer.")
    }

    private func restingWidth(in size: CGSize, landscape: Bool) -> CGFloat {
        if landscape { return min(size.width * 0.18, size.height * 0.30, 160) }
        return min(size.width * 0.32, size.height * 0.18, 150)
    }

    private func foregroundWidth(in size: CGSize, landscape: Bool) -> CGFloat {
        if landscape { return min(size.width * 0.26, size.height * 0.52, 250) }
        return min(size.width * 0.55, size.height * 0.32, 245)
    }

    private func restingBaseline(in size: CGSize, landscape: Bool) -> CGFloat {
        size.height * (landscape ? 0.63 : 0.60)
    }

    private func foregroundBaseline(in size: CGSize, landscape: Bool) -> CGFloat {
        size.height * (landscape ? 0.80 : 0.73)
    }

    private func journeyProgress(at date: Date) -> CGFloat {
        guard journeyDuration > 0 else { return journeyTo }
        let fraction = min(1, max(0, date.timeIntervalSince(journeyStart) / journeyDuration))
        let goingHome = journeyTo < journeyFrom
        let eased = goingHome ? walkHomeEase(fraction) : fraction * fraction * (3 - 2 * fraction)
        return journeyFrom + (journeyTo - journeyFrom) * eased
    }

    private func walkHomeEase(_ t: Double) -> Double {
        let t = min(1, max(0, t))
        if t < 0.14 {
            let u = t / 0.14
            return 0.10 * u * u
        }
        if t < 0.68 {
            return 0.10 + (t - 0.14) / 0.54 * 0.68
        }
        let u = (t - 0.68) / 0.32
        return 0.78 + 0.22 * (1 - (1 - u) * (1 - u))
    }

    private func startJourney(from: CGFloat, to: CGFloat, duration: TimeInterval) {
        journeyFrom = from
        journeyTo = to
        journeyDuration = duration
        journeyStart = .now
    }

    private func finishJourney(at progress: CGFloat) {
        startJourney(from: progress, to: progress, duration: 0)
    }

    private func facingFraction(at date: Date) -> CGFloat {
        guard facingDuration > 0 else { return 1 }
        let fraction = min(1, max(0, date.timeIntervalSince(facingStart) / facingDuration))
        return fraction * fraction * (3 - 2 * fraction)
    }

    private func facingProgress(at date: Date) -> CGFloat {
        facingFrom + (facingTo - facingFrom) * facingFraction(at: date)
    }

    private func startFacing(from: CGFloat, to: CGFloat, duration: TimeInterval) {
        facingFrom = from
        facingTo = to
        facingDuration = duration
        facingStart = .now
    }

    private func finishFacing(at progress: CGFloat) {
        startFacing(from: progress, to: progress, duration: 0)
    }

    private var settlingDuration: TimeInterval { reduceMotion ? 0.12 : 0.95 }

    private func walkStepRate() -> Double {
        switch phase {
        case .returning: 3.05
        case .approaching: 4.4
        default: 5.5
        }
    }

    private func settlingProgress(at date: Date) -> CGFloat {
        let fraction = min(1, max(0, date.timeIntervalSince(settlingStart) / settlingDuration))
        return fraction * fraction * (3 - 2 * fraction)
    }

    private func catTapped() {
        switch phase {
        case .sleeping:
            companion.perform(.meow, cue: .greeting)
            approach()
        case .goodbye:
            // Already beside the player: resume the greeting without a sleep/wake transition.
            greet()
        case .turningAway, .returning, .settling:
            companion.perform(.meow, cue: .greeting)
            recall()
        case .turningToward: break
        case .waking, .approaching: greet()
        case .greeting, .welcomed:
            companion.pet()
            watchForIdleReturn()
        }
    }

    private func approach() {
        let progress = journeyProgress(at: .now)
        stopSequence()
        finishJourney(at: progress)
        finishFacing(at: 0)
        recalledCurl = 0
        wakingStarted = .now
        phase = .waking
        sequence = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(reduceMotion ? 0.10 : 0.28))
                try Task.checkCancellation()
                let duration = reduceMotion ? 0.15 : max(0.35, 1.65 * (1 - progress))
                phase = .approaching
                startJourney(from: progress, to: 1, duration: duration)
                try await Task.sleep(for: .seconds(duration))
                try Task.checkCancellation()
                greet()
            } catch { /* Another tap, leaving the room, or backgrounding cancels this visit. */ }
        }
    }

    private func greet() {
        askedAgain = false
        stopSequence()
        companion.perform(.greet, cue: .greeting)
        finishJourney(at: 1)
        finishFacing(at: 0)
        recalledCurl = 0
        withAnimation(.easeOut(duration: reduceMotion ? 0.1 : 0.25)) { phase = .greeting }
        watchForIdleReturn()
    }

    private func acceptInvitation() {
        guard phase == .greeting else { return }
        askedAgain = false
        stopSequence()
        withAnimation(.easeInOut(duration: reduceMotion ? 0.12 : 0.4)) {
            phase = .welcomed
            isMenuVisible = true
        }
        watchForIdleReturn()
    }

    private func declineInvitation() {
        sendHome()
    }

    private func watchForIdleReturn() {
        cancelIdleReturn()
        guard !pauseIdle, scenePhase == .active else { return }
        idleReturn = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(5))
                try Task.checkCancellation()
                guard !pauseIdle else { return }
                if askedAgain {
                    sendHome()
                } else {
                    askAgain()
                }
            } catch { /* The player started, petted, or called the cat back. */ }
        }
    }

    private func askAgain() {
        guard phase == .greeting || phase == .welcomed else { return }
        askedAgain = true
        stopSequence()
        companion.perform(.meow, cue: .greeting)
        finishJourney(at: 1)
        finishFacing(at: 0)
        withAnimation(.easeInOut(duration: reduceMotion ? 0.12 : 0.35)) {
            isMenuVisible = false
            phase = .greeting
        }
        watchForIdleReturn()
    }

    private func cancelIdleReturn() {
        idleReturn?.cancel()
        idleReturn = nil
    }

    private func sendHome() {
        guard phase == .greeting || phase == .welcomed else { return }
        cancelIdleReturn()
        stopSequence()
        companion.perform(.encourage, cue: .goodbye)
        withAnimation(.easeOut(duration: 0.18)) {
            isMenuVisible = false
            phase = .goodbye
        }
        let minimumReadTime = max(1.6, min(4, Double(dialogueText.count) / 14))
        sequence = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(minimumReadTime))
                try Task.checkCancellation()
                let turnDuration = reduceMotion ? 0.15 : 0.78
                finishJourney(at: 1)
                withAnimation(.easeOut(duration: 0.2)) { phase = .turningAway }
                startFacing(from: 0, to: 1, duration: turnDuration)
                try await Task.sleep(for: .seconds(turnDuration))
                try Task.checkCancellation()
                finishFacing(at: 1)
                try await Task.sleep(for: .seconds(reduceMotion ? 0.04 : 0.28))
                try Task.checkCancellation()

                let duration = reduceMotion ? 0.18 : 2.35
                phase = .returning
                startJourney(from: 1, to: 0, duration: duration)
                try await Task.sleep(for: .seconds(duration))
                try Task.checkCancellation()
                finishJourney(at: 0)
                try await Task.sleep(for: .seconds(reduceMotion ? 0.05 : 0.34))
                try Task.checkCancellation()
                settlingStart = .now
                phase = .settling
                try await Task.sleep(for: .seconds(settlingDuration))
                try Task.checkCancellation()
                phase = .sleeping
            } catch { /* The cat can be called back at any point. */ }
        }
    }

    private func recall() {
        let now = Date.now
        let progress = journeyProgress(at: now)
        let facing = facingProgress(at: now)
        let curl = phase == .settling ? settlingProgress(at: now) : 0
        stopSequence()
        // Freeze the current point and perspective while the cat turns back.
        finishJourney(at: progress)
        recalledCurl = curl
        phase = .turningToward
        let turnDuration = reduceMotion ? 0.12 : 0.45 + 0.15 * Double(facing)
        startFacing(from: facing, to: 0, duration: turnDuration)
        sequence = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(turnDuration))
                try Task.checkCancellation()
                finishFacing(at: 0)
                recalledCurl = 0
                let duration = reduceMotion ? 0.15 : max(0.35, 1.65 * (1 - progress))
                phase = .approaching
                startJourney(from: progress, to: 1, duration: duration)
                try await Task.sleep(for: .seconds(duration))
                try Task.checkCancellation()
                greet()
            } catch { /* A cancelled return cannot later send the cat back to sleep. */ }
        }
    }

    private func stopSequence() {
        sequence?.cancel()
        sequence = nil
    }

    private func resetToRestingState() {
        askedAgain = false
        cancelIdleReturn()
        stopSequence()
        finishJourney(at: isMenuVisible ? 1 : 0)
        finishFacing(at: 0)
        recalledCurl = 0
        phase = isMenuVisible ? .welcomed : .sleeping
        if isMenuVisible { watchForIdleReturn() }
    }
}

private struct HomeCatBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX * 0.65, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: 0), control: CGPoint(x: rect.midX * 1.35, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
