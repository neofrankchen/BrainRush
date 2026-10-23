import Foundation

enum PlayerNames {
    private static let nameKey = "playerName"
    private static let idKey = "playerNameID"
    private static let avatarKey = "playerAvatar"
    private static let usageKey = "avatarUsage"
    private static let join = "+"
    static let fallbackAvatar = "🐾"
    static let frequentLimit = 12

    struct Item: Identifiable {
        let id: String
        var display: String { PlayerNames.display(id: id) }
        var emoji: String { PlayerNames.emoji(id: id) }
    }

    static func display(id: String) -> String {
        guard let (adj, animal) = parts(from: id) else { return id }
        let language = MainActor.assumeIsolated { LanguageStore.shared.language }
        func text(_ part: Part) -> String {
            let extra = ExtraLang.names[part.id]
            switch language {
            case .japanese: return part.ja
            case .chinese: return part.zh
            case .english: return part.en
            case .burmese: return part.my
            case .korean: return ExtraLang.first(extra?.ko, part.en)
            case .french: return ExtraLang.first(extra?.fr, part.en)
            case .traditional: return ExtraLang.first(extra?.zhHant, ExtraLang.toTraditional(part.zh))
            }
        }
        switch language {
        case .english, .burmese, .korean, .french:
            return text(adj) + " " + text(animal)
        default:
            return text(adj) + text(animal)
        }
    }

    static func emoji(id: String?) -> String {
        guard let id, let (_, animal) = parts(from: id), !animal.emoji.isEmpty else { return fallbackAvatar }
        return animal.emoji
    }

    enum AvatarGroup: String, CaseIterable, Identifiable {
        case frequent, smileys, nature, food, activity, travel, objects, symbols, flags

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .frequent: "🕒"
            case .smileys: "😀"
            case .nature: "🐻"
            case .food: "🍔"
            case .activity: "⚽"
            case .travel: "🚗"
            case .objects: "💡"
            case .symbols: "🔣"
            case .flags: "🏁"
            }
        }

        var title: String {
            switch self {
            case .frequent: tr(ja: "よく使う", zh: "常用", en: "Recents", my: "မကြာခဏ")
            case .smileys: tr(ja: "スマイルと人", zh: "表情与人物", en: "Smileys & People", my: "မျက်နှာနှင့် လူ")
            case .nature: tr(ja: "動物と自然", zh: "动物与自然", en: "Animals & Nature", my: "တိရစ္ဆာန်နှင့် သဘာဝ")
            case .food: tr(ja: "食べ物と飲み物", zh: "食物与饮料", en: "Food & Drink", my: "အစားအသောက်")
            case .activity: tr(ja: "アクティビティ", zh: "活动", en: "Activity", my: "လှုပ်ရှားမှု")
            case .travel: tr(ja: "場所と旅行", zh: "旅行与地点", en: "Travel & Places", my: "ခရီးနှင့် နေရာ")
            case .objects: tr(ja: "オブジェクト", zh: "物品", en: "Objects", my: "ပစ္စည်း")
            case .symbols: tr(ja: "記号", zh: "符号", en: "Symbols", my: "သင်္ကေတ")
            case .flags: tr(ja: "旗", zh: "旗帜", en: "Flags", my: "အလံ")
            }
        }
    }

    static let avatars: [String] = makeCatalog()

    private static let groupedAvatars: [AvatarGroup: [String]] = {
        var dict: [AvatarGroup: [String]] = [:]
        for emoji in avatars {
            dict[classify(emoji), default: []].append(emoji)
        }
        return dict
    }()

    static func avatars(in group: AvatarGroup) -> [String] {
        if group == .frequent { return frequentAvatars }
        return groupedAvatars[group] ?? []
    }

    static var frequentAvatars: [String] {
        let counts = UserDefaults.standard.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
        return counts
            .filter { !$0.key.isEmpty && $0.value > 0 }
            .sorted { lhs, rhs in
                if lhs.value != rhs.value { return lhs.value > rhs.value }
                return lhs.key < rhs.key
            }
            .prefix(frequentLimit)
            .map(\.key)
    }

    static func recordAvatarUse(_ emoji: String) {
        guard !emoji.isEmpty else { return }
        var counts = UserDefaults.standard.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
        counts[emoji, default: 0] += 1
        UserDefaults.standard.set(counts, forKey: usageKey)
    }

    private static func makeCatalog() -> [String] {
        var seen = Set<String>()
        var list: [String] = []
        func add(_ value: String) {
            guard !value.isEmpty, seen.insert(value).inserted else { return }
            list.append(value)
        }
        add(fallbackAvatar)
        animals.map(\.emoji).forEach(add)
        let ranges: [ClosedRange<UInt32>] = [
            0x1F004...0x1F0CF,
            0x1F170...0x1F251,
            0x1F300...0x1F5FF,
            0x1F600...0x1F64F,
            0x1F680...0x1F6FF,
            0x1F7E0...0x1F7EB,
            0x1F90C...0x1F9FF,
            0x1FA70...0x1FAFF,
            0x2600...0x26FF,
            0x2700...0x27BF,
            0x2B50...0x2B55,
            0x231A...0x23FA,
        ]
        for range in ranges {
            for code in range {
                guard let scalar = Unicode.Scalar(code), scalar.properties.isEmoji else { continue }
                if (0x1F3FB...0x1F3FF).contains(code) { continue }
                let text = scalar.properties.isEmojiPresentation ? String(scalar) : String(scalar) + "\u{FE0F}"
                add(text)
            }
        }
        add("#\u{FE0F}\u{20E3}")
        add("*\u{FE0F}\u{20E3}")
        for digit in 0...9 {
            add("\(digit)\u{FE0F}\u{20E3}")
        }
        for first in 0x1F1E6...0x1F1FF {
            for second in 0x1F1E6...0x1F1FF {
                guard let a = Unicode.Scalar(first), let b = Unicode.Scalar(second) else { continue }
                let flag = String(a) + String(b)
                if flag.count == 1 { add(flag) }
            }
        }
        return list
    }

    private static let groupRanges: [(ClosedRange<UInt32>, AvatarGroup)] = [
        (0x1F1E6...0x1F1FF, .flags),
        (0x1F3F3...0x1F3F4, .flags),
        (0x1F38C...0x1F38C, .flags),
        (0x1F6A9...0x1F6A9, .flags),
        (0x1F32D...0x1F37F, .food),
        (0x1F950...0x1F96F, .food),
        (0x1F9C0...0x1F9CB, .food),
        (0x1FAD0...0x1FAD9, .food),
        (0x2615...0x2615, .food),
        (0x1F336...0x1F336, .food),
        (0x1F400...0x1F43F, .nature),
        (0x1F980...0x1F9AE, .nature),
        (0x1FAB0...0x1FABF, .nature),
        (0x1F330...0x1F344, .nature),
        (0x1F331...0x1F343, .nature),
        (0x1F490...0x1F490, .nature),
        (0x1F338...0x1F33F, .nature),
        (0x1F940...0x1F940, .nature),
        (0x1F54A...0x1F54A, .nature),
        (0x1F577...0x1F578, .nature),
        (0x1F300...0x1F30C, .nature),
        (0x1F311...0x1F31F, .nature),
        (0x1F525...0x1F525, .nature),
        (0x1F4A7...0x1F4A7, .nature),
        (0x2600...0x2603, .nature),
        (0x2618...0x2618, .nature),
        (0x26C4...0x26C8, .nature),
        (0x1F321...0x1F321, .nature),
        (0x1F324...0x1F32C, .nature),
        (0x1F3F5...0x1F3F5, .nature),
        (0x1F3A0...0x1F3D3, .activity),
        (0x1F3F8...0x1F3F9, .activity),
        (0x1F947...0x1F94F, .activity),
        (0x1FA80...0x1FA87, .activity),
        (0x1F380...0x1F384, .activity),
        (0x1F386...0x1F38B, .activity),
        (0x1F38D...0x1F391, .activity),
        (0x1F396...0x1F39F, .activity),
        (0x26BD...0x26BE, .activity),
        (0x26F3...0x26F3, .activity),
        (0x26F7...0x26F9, .activity),
        (0x265F...0x265F, .activity),
        (0x1F9E7...0x1F9E9, .activity),
        (0x1F004...0x1F0CF, .activity),
        (0x1F6F9...0x1F6F9, .activity),
        (0x1F3D4...0x1F3F0, .travel),
        (0x1F5FA...0x1F5FF, .travel),
        (0x1F301...0x1F307, .travel),
        (0x1F309...0x1F310, .travel),
        (0x1F320...0x1F320, .travel),
        (0x1F680...0x1F6A8, .travel),
        (0x1F6AA...0x1F6AA, .objects),
        (0x1F6B2...0x1F6B2, .travel),
        (0x1F6B4...0x1F6B6, .smileys),
        (0x1F6BD...0x1F6C1, .objects),
        (0x1F6AB...0x1F6C5, .symbols),
        (0x1F6CB...0x1F6CF, .objects),
        (0x1F6D0...0x1F6D0, .symbols),
        (0x1F6D1...0x1F6D1, .travel),
        (0x1F6D2...0x1F6D2, .objects),
        (0x1F6D5...0x1F6DF, .travel),
        (0x1F6E0...0x1F6E1, .objects),
        (0x1F6E2...0x1F6F8, .travel),
        (0x1F6FA...0x1F6FF, .travel),
        (0x26F0...0x26F0, .travel),
        (0x26F4...0x26F5, .travel),
        (0x26FA...0x26FA, .travel),
        (0x26FD...0x26FD, .travel),
        (0x2693...0x2693, .travel),
        (0x26EA...0x26EA, .travel),
        (0x1F54B...0x1F54D, .travel),
        (0x1F9ED...0x1F9ED, .travel),
        (0x1F9F3...0x1F9F3, .travel),
        (0x1F600...0x1F64F, .smileys),
        (0x1F910...0x1F92F, .smileys),
        (0x1F970...0x1F97A, .smileys),
        (0x1F973...0x1F979, .smileys),
        (0x1F47B...0x1F480, .smileys),
        (0x1F608...0x1F608, .smileys),
        (0x1F47F...0x1F47F, .smileys),
        (0x1F4A9...0x1F4A9, .smileys),
        (0x1F4A2...0x1F4A2, .smileys),
        (0x1F4A4...0x1F4A6, .smileys),
        (0x1F4A8...0x1F4A8, .smileys),
        (0x1F4AB...0x1F4AD, .smileys),
        (0x1F48B...0x1F49F, .smileys),
        (0x1F5A4...0x1F5A4, .smileys),
        (0x1F90D...0x1F90E, .smileys),
        (0x1F9E1...0x1F9E1, .smileys),
        (0x1FA75...0x1FA77, .smileys),
        (0x1FAE0...0x1FAE8, .smileys),
        (0x2639...0x263A, .smileys),
        (0x2763...0x2764, .smileys),
        (0x2620...0x2620, .smileys),
        (0x1F5E8...0x1F5E8, .smileys),
        (0x1F5EF...0x1F5EF, .smileys),
        (0x1F440...0x1F478, .smileys),
        (0x1F481...0x1F487, .smileys),
        (0x1F385...0x1F385, .smileys),
        (0x1F930...0x1F93A, .smileys),
        (0x1F9B0...0x1F9BF, .smileys),
        (0x1F9D0...0x1F9DF, .smileys),
        (0x1FAC0...0x1FACE, .smileys),
        (0x1F90C...0x1F90C, .smileys),
        (0x1F90F...0x1F90F, .smileys),
        (0x1F91A...0x1F91F, .smileys),
        (0x1F590...0x1F590, .smileys),
        (0x270A...0x270D, .smileys),
        (0x261D...0x261D, .smileys),
        (0x1F57A...0x1F57A, .smileys),
        (0x1F574...0x1F575, .smileys),
        (0x1F9E0...0x1F9E0, .smileys),
        (0x1F451...0x1F462, .smileys),
        (0x1F9E2...0x1F9E6, .smileys),
        (0x1F97C...0x1F97F, .smileys),
        (0x1FA70...0x1FA74, .smileys),
        (0x1F392...0x1F393, .smileys),
        (0x1F3A9...0x1F3A9, .smileys),
        (0x1F452...0x1F452, .smileys),
        (0x1F576...0x1F576, .smileys),
        (0x1F46A...0x1F46F, .smileys),
        (0x1F48D...0x1F48F, .smileys),
        (0x1F491...0x1F492, .smileys),
        (0x1F6B6...0x1F6B6, .smileys),
        (0x1F4A0...0x1F4FF, .objects),
        (0x1F50D...0x1F52E, .objects),
        (0x1F5A5...0x1F5B2, .objects),
        (0x1F5BC...0x1F5BC, .objects),
        (0x1F5C2...0x1F5C4, .objects),
        (0x1F5D1...0x1F5D3, .objects),
        (0x1F5DC...0x1F5E1, .objects),
        (0x1F56F...0x1F570, .objects),
        (0x1F58A...0x1F58D, .objects),
        (0x2328...0x2328, .objects),
        (0x1F9F0...0x1F9FF, .objects),
        (0x1FA90...0x1FA9F, .objects),
        (0x1FA78...0x1FA7C, .objects),
        (0x1F489...0x1F48A, .objects),
        (0x2692...0x2692, .objects),
        (0x2694...0x2694, .objects),
        (0x2696...0x2697, .objects),
        (0x2699...0x2699, .objects),
        (0x26B0...0x26B1, .objects),
        (0x26CF...0x26CF, .objects),
        (0x26D1...0x26D1, .objects),
        (0x26D3...0x26D3, .objects),
        (0x2702...0x2702, .objects),
        (0x1F3F7...0x1F3F7, .objects),
        (0x1F7E0...0x1F7EB, .symbols),
        (0x1F500...0x1F53D, .symbols),
        (0x1F191...0x1F19A, .symbols),
        (0x1F201...0x1F251, .symbols),
        (0x23E9...0x23FA, .symbols),
        (0x2B05...0x2B07, .symbols),
        (0x2B1B...0x2B1C, .symbols),
        (0x2B50...0x2B55, .symbols),
        (0x25AA...0x25FE, .symbols),
        (0x2648...0x2653, .symbols),
        (0x2660...0x2668, .symbols),
        (0x267B...0x267F, .symbols),
        (0x26A0...0x26AB, .symbols),
        (0x2705...0x2705, .symbols),
        (0x2714...0x2716, .symbols),
        (0x274C...0x274E, .symbols),
        (0x2753...0x2757, .symbols),
        (0x2795...0x2797, .symbols),
        (0x27A1...0x27A1, .symbols),
        (0x27B0...0x27BF, .symbols),
        (0x1F170...0x1F18E, .symbols),
    ]

    private static func classify(_ emoji: String) -> AvatarGroup {
        let scalars = emoji.unicodeScalars
        if scalars.count == 2,
           scalars.allSatisfy({ (0x1F1E6...0x1F1FF).contains($0.value) }) {
            return .flags
        }
        if emoji.hasSuffix("\u{20E3}") { return .symbols }
        guard let code = scalars.first?.value else { return .symbols }
        for (range, group) in groupRanges where range.contains(code) {
            return group
        }
        return .symbols
    }

    static func isKnown(_ id: String) -> Bool {
        parts(from: id) != nil
    }

    static func random() -> Item {
        make(adj: adjectives.randomElement() ?? adjectives[0], animal: animals.randomElement() ?? animals[0])
    }

    static func randomAdjective(keeping id: String?) -> Item {
        let current = id.flatMap(parts(from:))
        let animal = current?.1 ?? animals.randomElement() ?? animals[0]
        let pool = adjectives.filter { $0.id != current?.0.id }
        let adj = (pool.randomElement() ?? adjectives.randomElement()) ?? adjectives[0]
        return make(adj: adj, animal: animal)
    }

    static func randomAnimal(keeping id: String?) -> Item {
        let current = id.flatMap(parts(from:))
        let adj = current?.0 ?? adjectives.randomElement() ?? adjectives[0]
        let pool = animals.filter { $0.id != current?.1.id }
        let animal = (pool.randomElement() ?? animals.randomElement()) ?? animals[0]
        return make(adj: adj, animal: animal)
    }

    static func loadLast() -> (id: String?, name: String, avatar: String) {
        let id = UserDefaults.standard.string(forKey: idKey)
        let name = UserDefaults.standard.string(forKey: nameKey) ?? ""
        let stored = UserDefaults.standard.string(forKey: avatarKey) ?? ""
        let avatar = stored.isEmpty ? emoji(id: id) : stored
        return (id, name, avatar)
    }

    static func saveLast(id: String?, name: String, avatar: String) {
        UserDefaults.standard.set(name, forKey: nameKey)
        UserDefaults.standard.set(avatar, forKey: avatarKey)
        if let id {
            UserDefaults.standard.set(id, forKey: idKey)
        } else {
            UserDefaults.standard.removeObject(forKey: idKey)
        }
    }

    private struct Part {
        let id: String
        let ja: String
        let zh: String
        let en: String
        let my: String
        var emoji: String = ""
    }

    private static func make(adj: Part, animal: Part) -> Item {
        Item(id: "\(adj.id)\(join)\(animal.id)")
    }

    private static func animal(
        _ id: String,
        _ emoji: String,
        ja: String,
        zh: String,
        en: String,
        my: String
    ) -> Part {
        Part(id: id, ja: ja, zh: zh, en: en, my: my, emoji: emoji)
    }

    private static func parts(from id: String) -> (Part, Part)? {
        let bits = id.split(separator: "+", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
        guard bits.count == 2,
              let adj = adjectives.first(where: { $0.id == bits[0] }),
              let animal = animals.first(where: { $0.id == bits[1] })
        else { return nil }
        return (adj, animal)
    }

    private static let adjectives: [Part] = [
        Part(id: "genius", ja: "自称天才の", zh: "自称天才的", en: "Self-proclaimed genius", my: "ကိုယ့်ကိုယ် ဉာဏ်ကြီးသည်ဆိုသော"),
        Part(id: "probably-genius", ja: "たぶん天才の", zh: "大概是天才的", en: "Probably-a-genius", my: "ဖြစ်နိုင်သည် ဉာဏ်ကြီးသော"),
        Part(id: "mystery-confident", ja: "なぜか自信満々の", zh: "不知为何自信满满的", en: "Mysteriously-full-of-confidence", my: "ဘာကြောင့်မှန်းမသိ ယုံကြည်မှုပြည့်သော"),
        Part(id: "iq999", ja: "IQ999の", zh: "IQ999的", en: "IQ999", my: "IQ999"),
        Part(id: "worlds-smartest", ja: "世界一賢い（自称）", zh: "世界第一聪明的（自称）", en: "World's-smartest (self-proclaimed)", my: "ကမ္ဘာ့အလိမ္မာဆုံး (ကိုယ့်ကိုယ်ဆိုသော)"),
        Part(id: "thinks-genius", ja: "自分を天才だと思っている", zh: "觉得自己是天才的", en: "Thinks-it's-a-genius", my: "ကိုယ့်ကိုယ် ဉာဏ်ကြီးသည်ထင်သော"),
        Part(id: "not-trying", ja: "まだ本気を出していない", zh: "还没拿出真本事的", en: "Hasn't-tried-yet", my: "စစ်မှန်အရည်အချင်း မထုတ်သေးသော"),
        Part(id: "almost-genius", ja: "天才になりかけの", zh: "差一点成为天才的", en: "Almost-a-genius", my: "ဉာဏ်ကြီးသူဖြစ်ခါနီးသော"),
        Part(id: "sleepy", ja: "寝起きの", zh: "刚睡醒的", en: "Just-woke-up", my: "ခုမှနိုးသော"),
        Part(id: "summer-brain", ja: "頭の中が夏休みの", zh: "脑子正在放暑假的", en: "Brain-on-summer-break", my: "ဦးနှောက်နွေရာသီအားလပ်ရက်ယူနေသော"),
        Part(id: "forgetful", ja: "3秒で忘れる", zh: "3秒就忘事的", en: "3-second-memory", my: "၃ စက္ကန့်နှင့် မေ့သော"),
        Part(id: "always-sleepy", ja: "いつも眠そうな", zh: "永远睡不醒的", en: "Always-sleepy", my: "အမြဲ အိပ်ချင်နေသော"),
        Part(id: "quit-thinking", ja: "考えるのをやめた", zh: "放弃思考的", en: "Gave-up-thinking", my: "တွေးခြင်း ရပ်လိုက်သော"),
        Part(id: "blank-mind", ja: "頭が真っ白な", zh: "脑子一片空白的", en: "Mind-gone-blank", my: "ဦးနှောက်ဗလာဖြစ်သော"),
        Part(id: "ex-genius", ja: "昨日まで天才だった", zh: "昨天还是天才的", en: "Was-a-genius-yesterday", my: "မနေ့က ဉာဏ်ကြီးသူ ဖြစ်ခဲ့သော"),
        Part(id: "sketchy-memory", ja: "記憶力が怪しい", zh: "记忆力不太可靠的", en: "Sketchy-memory", my: "မှတ်ဉာဏ် မခိုင်သော"),
        Part(id: "dinner", ja: "晩ごはんで悩む", zh: "正在纠结晚饭的", en: "Dinner-dilemma", my: "ညစာတွေးနေသော"),
        Part(id: "homework", ja: "宿題を忘れた", zh: "忘记写作业的", en: "Forgot-homework", my: "အိမ်စာမေ့သော"),
        Part(id: "try-tomorrow", ja: "明日から本気を出す", zh: "明天开始认真努力的", en: "Starts-trying-tomorrow", my: "မနက်ဖြန်မှ အလေးအနက်လုပ်မည့်"),
        Part(id: "escaping", ja: "現実逃避中の", zh: "正在逃避现实的", en: "Reality-escaping", my: "လက်တွေ့ကို ရှောင်နေသော"),
        Part(id: "secret-study", ja: "こっそり勉強中の", zh: "正在偷偷学习的", en: "Secretly-studying", my: "လျှို့ဝှက်စာကျက်နေသော"),
        Part(id: "weekend-energy", ja: "週末だけ元気な", zh: "只有周末才精神的", en: "Energetic-only-on-weekends", my: "ပိတ်ရက်သာ စိတ်ဓာတ်ရှိသော"),
        Part(id: "no-direction", ja: "方向音痴の", zh: "路痴的", en: "Gets-lost-easily", my: "လမ်းမှားလွယ်သော"),
        Part(id: "empty-thoughts", ja: "何も考えていない", zh: "什么都没想的", en: "Thinking-of-nothing", my: "ဘာမှ မတွေးသော"),
        Part(id: "actually-boss", ja: "実は社長の", zh: "其实是社长的", en: "Secretly-the-boss", my: "တကယ်တော့ ဥက္ကဋ္ဌဖြစ်သော"),
        Part(id: "world-domination", ja: "世界征服を企む", zh: "企图征服世界的", en: "Plotting-world-domination", my: "ကမ္ဘာကို သိမ်းပိုက်ရန် ကြံသော"),
        Part(id: "wants-legend", ja: "伝説になりたい", zh: "想成为传说的", en: "Wants-to-be-a-legend", my: "ဒဏ္ဍာရီဖြစ်ချင်သော"),
        Part(id: "from-space", ja: "宇宙から来た", zh: "从宇宙来的", en: "Came-from-space", my: "အာကာသမှ လာသော"),
        Part(id: "past-life-human", ja: "前世は人間だった", zh: "上辈子是人类的", en: "Was-human-in-a-past-life", my: "ရှေးဘဝက လူဖြစ်ခဲ့သော"),
        Part(id: "from-future", ja: "未来から来た", zh: "来自未来的", en: "Came-from-the-future", my: "အနာဂတ်မှ လာသော"),
        Part(id: "suddenly-talking", ja: "突然しゃべり出した", zh: "突然开口说话的", en: "Suddenly-started-talking", my: "ရုတ်တရက် စကားပြောလာသော"),
        Part(id: "second-life", ja: "人生2周目の", zh: "正在过第二次人生的", en: "On-its-second-life", my: "ဘဝဒုတိယပတ် နေသော"),
    ]

    private static let animals: [Part] = [
        animal("cat", "🐱", ja: "ネコ", zh: "猫", en: "cat", my: "ကြောင်"),
        animal("black-cat", "🐈‍⬛", ja: "黒ネコ", zh: "黑猫", en: "black cat", my: "ကြောင်မည်း"),
        animal("dog", "🐶", ja: "イヌ", zh: "狗", en: "dog", my: "ခွေး"),
        animal("shiba", "🐕", ja: "柴犬", zh: "柴犬", en: "shiba", my: "ရှိဘ"),
        animal("poodle", "🐩", ja: "プードル", zh: "贵宾犬", en: "poodle", my: "ပူဒယ်"),
        animal("wolf", "🐺", ja: "オオカミ", zh: "狼", en: "wolf", my: "ဝံပုလွေ"),
        animal("fox", "🦊", ja: "キツネ", zh: "狐狸", en: "fox", my: "မြေခွေး"),
        animal("lion", "🦁", ja: "ライオン", zh: "狮子", en: "lion", my: "ခြင်္သေ့"),
        animal("tiger", "🐯", ja: "トラ", zh: "老虎", en: "tiger", my: "ကျား"),
        animal("leopard", "🐆", ja: "ヒョウ", zh: "豹", en: "leopard", my: "ကျားသစ်"),
        animal("horse", "🐴", ja: "ウマ", zh: "马", en: "horse", my: "မြင်း"),
        animal("unicorn", "🦄", ja: "ユニコーン", zh: "独角兽", en: "unicorn", my: "ယူနီကွန်"),
        animal("zebra", "🦓", ja: "シマウマ", zh: "斑马", en: "zebra", my: "မြင်းကျား"),
        animal("deer", "🦌", ja: "シカ", zh: "鹿", en: "deer", my: "သမင်"),
        animal("moose", "🫎", ja: "ヘラジカ", zh: "驼鹿", en: "moose", my: "မုစ်"),
        animal("donkey", "🫏", ja: "ロバ", zh: "驴", en: "donkey", my: "မြည်း"),
        animal("cow", "🐮", ja: "ウシ", zh: "牛", en: "cow", my: "နွား"),
        animal("ox", "🐂", ja: "オウシ", zh: "公牛", en: "ox", my: "နွားထီး"),
        animal("water-buffalo", "🐃", ja: "スイギュウ", zh: "水牛", en: "water buffalo", my: "ကျွဲ"),
        animal("bison", "🦬", ja: "バイソン", zh: "野牛", en: "bison", my: "ဘိုင်ဆန်"),
        animal("pig", "🐷", ja: "ブタ", zh: "猪", en: "pig", my: "ဝက်"),
        animal("boar", "🐗", ja: "イノシシ", zh: "野猪", en: "boar", my: "တောဝက်"),
        animal("ram", "🐏", ja: "オスヒツジ", zh: "公羊", en: "ram", my: "သိုးထီး"),
        animal("sheep", "🐑", ja: "ヒツジ", zh: "绵羊", en: "sheep", my: "သိုး"),
        animal("goat", "🐐", ja: "ヤギ", zh: "山羊", en: "goat", my: "ဆိတ်"),
        animal("camel", "🐪", ja: "ラクダ", zh: "骆驼", en: "camel", my: "ကုလားအုတ်"),
        animal("two-hump-camel", "🐫", ja: "フタコブラクダ", zh: "双峰驼", en: "two-hump camel", my: "ကုလားအုတ်နှစ်ကုန်း"),
        animal("llama", "🦙", ja: "ラマ", zh: "羊驼", en: "llama", my: "လာမ"),
        animal("giraffe", "🦒", ja: "キリン", zh: "长颈鹿", en: "giraffe", my: "သစ်ကုလားအုပ်"),
        animal("elephant", "🐘", ja: "ゾウ", zh: "大象", en: "elephant", my: "ဆင်"),
        animal("mammoth", "🦣", ja: "マンモス", zh: "猛犸", en: "mammoth", my: "မမ်မသ်"),
        animal("rhino", "🦏", ja: "サイ", zh: "犀牛", en: "rhino", my: "ကြံ့"),
        animal("hippo", "🦛", ja: "カバ", zh: "河马", en: "hippo", my: "ရေမြင်း"),
        animal("mouse", "🐭", ja: "ネズミ", zh: "老鼠", en: "mouse", my: "ကြွက်"),
        animal("rat", "🐀", ja: "ドブネズミ", zh: "沟鼠", en: "rat", my: "ကြွက်ကြီး"),
        animal("hamster", "🐹", ja: "ハムスター", zh: "仓鼠", en: "hamster", my: "ကြွက်ကလေး"),
        animal("rabbit", "🐰", ja: "ウサギ", zh: "兔子", en: "rabbit", my: "ယုန်"),
        animal("chipmunk", "🐿️", ja: "シマリス", zh: "花栗鼠", en: "chipmunk", my: "ချစ်ပ်မန့်"),
        animal("beaver", "🦫", ja: "ビーバー", zh: "海狸", en: "beaver", my: "ဘီဗာ"),
        animal("hedgehog", "🦔", ja: "ハリネズミ", zh: "刺猬", en: "hedgehog", my: "ပြောင်"),
        animal("bat", "🦇", ja: "コウモリ", zh: "蝙蝠", en: "bat", my: "လင်းနို့"),
        animal("bear", "🐻", ja: "クマ", zh: "熊", en: "bear", my: "ဝက်ဝံ"),
        animal("polar-bear", "🐻‍❄️", ja: "シロクマ", zh: "北极熊", en: "polar bear", my: "ဝက်ဝံဖြူ"),
        animal("koala", "🐨", ja: "コアラ", zh: "考拉", en: "koala", my: "ကိုအာလာ"),
        animal("panda", "🐼", ja: "パンダ", zh: "熊猫", en: "panda", my: "ပန်ဒါ"),
        animal("sloth", "🦥", ja: "ナマケモノ", zh: "树懒", en: "sloth", my: "သစ်ပုတ်"),
        animal("otter", "🦦", ja: "カワウソ", zh: "水獭", en: "otter", my: "ရေဖျံ"),
        animal("skunk", "🦨", ja: "スカンク", zh: "臭鼬", en: "skunk", my: "စကန့်"),
        animal("kangaroo", "🦘", ja: "カンガルー", zh: "袋鼠", en: "kangaroo", my: "ကန်ဂါရု"),
        animal("badger", "🦡", ja: "アナグマ", zh: "獾", en: "badger", my: "ဘက်ဂျာ"),
        animal("raccoon", "🦝", ja: "アライグマ", zh: "浣熊", en: "raccoon", my: "ရက်ကွန်း"),
        animal("gorilla", "🦍", ja: "ゴリラ", zh: "大猩猩", en: "gorilla", my: "လူဝံ"),
        animal("orangutan", "🦧", ja: "オランウータン", zh: "猩猩", en: "orangutan", my: "အိုရန်ဂူတန်"),
        animal("monkey", "🐵", ja: "サル", zh: "猴子", en: "monkey", my: "မျောက်"),
        animal("penguin", "🐧", ja: "ペンギン", zh: "企鹅", en: "penguin", my: "ပင်ဂွင်း"),
        animal("owl", "🦉", ja: "フクロウ", zh: "猫头鹰", en: "owl", my: "ဇီးကွက်"),
        animal("dove", "🕊️", ja: "ハト", zh: "鸽子", en: "dove", my: "ချိုး"),
        animal("eagle", "🦅", ja: "ワシ", zh: "鹰", en: "eagle", my: "လင်းယုန်"),
        animal("duck", "🦆", ja: "アヒル", zh: "鸭子", en: "duck", my: "ဘဲ"),
        animal("swan", "🦢", ja: "ハクチョウ", zh: "天鹅", en: "swan", my: "ငန်းဖြူ"),
        animal("dodo", "🦤", ja: "ドードー", zh: "渡渡鸟", en: "dodo", my: "ဒိုဒို"),
        animal("flamingo", "🦩", ja: "フラミンゴ", zh: "火烈鸟", en: "flamingo", my: "ဖလမင်ဂို"),
        animal("peacock", "🦚", ja: "クジャク", zh: "孔雀", en: "peacock", my: "ဒေါင်း"),
        animal("parrot", "🦜", ja: "オウム", zh: "鹦鹉", en: "parrot", my: "ကြက်တူရွေး"),
        animal("rooster", "🐓", ja: "オンドリ", zh: "公鸡", en: "rooster", my: "ကြက်ဖ"),
        animal("chicken", "🐔", ja: "ニワトリ", zh: "鸡", en: "chicken", my: "ကြက်"),
        animal("chick", "🐣", ja: "ヒヨコ", zh: "小鸡", en: "chick", my: "ကြက်ကလေး"),
        animal("turkey", "🦃", ja: "シチメンチョウ", zh: "火鸡", en: "turkey", my: "တူရကီကြက်"),
        animal("goose", "🪿", ja: "ガチョウ", zh: "鹅", en: "goose", my: "ငန်း"),
        animal("crow", "🐦‍⬛", ja: "カラス", zh: "乌鸦", en: "crow", my: "ကျီး"),
        animal("bird", "🐦", ja: "トリ", zh: "鸟", en: "bird", my: "ငှက်"),
        animal("frog", "🐸", ja: "カエル", zh: "青蛙", en: "frog", my: "ဖား"),
        animal("crocodile", "🐊", ja: "ワニ", zh: "鳄鱼", en: "crocodile", my: "မိကျောင်း"),
        animal("turtle", "🐢", ja: "カメ", zh: "乌龟", en: "turtle", my: "လိပ်"),
        animal("lizard", "🦎", ja: "トカゲ", zh: "蜥蜴", en: "lizard", my: "ပုတ်သင်ညို"),
        animal("snake", "🐍", ja: "ヘビ", zh: "蛇", en: "snake", my: "မြွေ"),
        animal("sauropod", "🦕", ja: "草食恐竜", zh: "长颈龙", en: "sauropod", my: "ဆောရိုပေါ့ဒ်"),
        animal("t-rex", "🦖", ja: "ティラノサウルス", zh: "霸王龙", en: "T-rex", my: "တီရက်ခ်စ်"),
        animal("whale", "🐳", ja: "クジラ", zh: "鲸", en: "whale", my: "ဝေလငါး"),
        animal("dolphin", "🐬", ja: "イルカ", zh: "海豚", en: "dolphin", my: "လင်းပိုင်"),
        animal("seal", "🦭", ja: "アザラシ", zh: "海豹", en: "seal", my: "ဖျံ"),
        animal("fish", "🐟", ja: "サカナ", zh: "鱼", en: "fish", my: "ငါး"),
        animal("tropical-fish", "🐠", ja: "熱帯魚", zh: "热带鱼", en: "tropical fish", my: "အပူပိုင်းငါး"),
        animal("blowfish", "🐡", ja: "フグ", zh: "河豚", en: "blowfish", my: "ဖူဂု"),
        animal("shark", "🦈", ja: "サメ", zh: "鲨鱼", en: "shark", my: "ငါးမန်း"),
        animal("octopus", "🐙", ja: "タコ", zh: "章鱼", en: "octopus", my: "ရေဘဝဲ"),
        animal("squid", "🦑", ja: "イカ", zh: "鱿鱼", en: "squid", my: "ရွှေငါး"),
        animal("shrimp", "🦐", ja: "エビ", zh: "虾", en: "shrimp", my: "ပုဇွန်"),
        animal("lobster", "🦞", ja: "ロブスター", zh: "龙虾", en: "lobster", my: "ပုဇွန်ကြီး"),
        animal("crab", "🦀", ja: "カニ", zh: "螃蟹", en: "crab", my: "ကဏန်း"),
        animal("jellyfish", "🪼", ja: "クラゲ", zh: "水母", en: "jellyfish", my: "ပင်လယ်ပက်ကျိ"),
        animal("snail", "🐌", ja: "カタツムリ", zh: "蜗牛", en: "snail", my: "ခရု"),
        animal("butterfly", "🦋", ja: "チョウ", zh: "蝴蝶", en: "butterfly", my: "လိပ်ပြာ"),
        animal("bug", "🐛", ja: "イモムシ", zh: "毛虫", en: "caterpillar", my: "လိပ်ပြာကောင်"),
        animal("ant", "🐜", ja: "アリ", zh: "蚂蚁", en: "ant", my: "ပုရွက်ဆိတ်"),
        animal("bee", "🐝", ja: "ハチ", zh: "蜜蜂", en: "bee", my: "ပျား"),
        animal("beetle", "🪲", ja: "カブトムシ", zh: "甲虫", en: "beetle", my: "ပိုးအခွံမာ"),
        animal("ladybug", "🐞", ja: "テントウムシ", zh: "瓢虫", en: "ladybug", my: "လေဒီဘတ်"),
        animal("cricket", "🦗", ja: "コオロギ", zh: "蟋蟀", en: "cricket", my: "ကျိုင်းကောင်"),
        animal("cockroach", "🪳", ja: "ゴキブリ", zh: "蟑螂", en: "cockroach", my: "ပိုးတုံးလုံး"),
        animal("spider", "🕷️", ja: "クモ", zh: "蜘蛛", en: "spider", my: "ပင့်ကူ"),
        animal("scorpion", "🦂", ja: "サソリ", zh: "蝎子", en: "scorpion", my: "ကင်းမြီးကောက်"),
        animal("mosquito", "🦟", ja: "カ", zh: "蚊子", en: "mosquito", my: "ခြင်"),
        animal("fly", "🪰", ja: "ハエ", zh: "苍蝇", en: "fly", my: "ယင်ကောင်"),
        animal("worm", "🪱", ja: "ミミズ", zh: "蚯蚓", en: "worm", my: "တီကောင်"),
        animal("dragon", "🐲", ja: "ドラゴン", zh: "龙", en: "dragon", my: "နဂါး"),
    ]
}
