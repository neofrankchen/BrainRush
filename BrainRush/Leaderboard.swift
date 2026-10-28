import SwiftUI

enum ScoreRank {
    case high
    case low
    case tenths
    case match
    case timed
}

struct ScoreRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var score: Int
    var detail: Int
    var created: Date
    var name: String
    var avatar: String
    var language: String

    init(id: UUID, score: Int, detail: Int, created: Date, name: String, avatar: String = "", language: String = "") {
        self.id = id
        self.score = score
        self.detail = detail
        self.created = created
        self.name = name
        self.avatar = avatar
        self.language = language
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        score = try container.decode(Int.self, forKey: .score)
        detail = try container.decode(Int.self, forKey: .detail)
        created = try container.decode(Date.self, forKey: .created)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
    }
}

enum ScoreBoardFilter: Hashable {
    case all
    case language(AppLanguage)
}

enum ScoreBoard {
    private static let generationKey = "scoreboard.generation"
    private static let generation = 10

    static func records(for game: String, filter: ScoreBoardFilter = .all) -> [ScoreRecord] {
        resetStaleBoardsIfNeeded()
        switch filter {
        case .all:
            return stored(for: game)
        case .language(let language):
            return stored(for: "\(game).\(language.rawValue)")
        }
    }

    @discardableResult
    static func submit(
        game: String,
        score: Int,
        detail: Int = 0,
        name: String = "",
        avatar: String = "",
        language: AppLanguage,
        rank: ScoreRank
    ) -> UUID? {
        resetStaleBoardsIfNeeded()
        let entry = ScoreRecord(
            id: UUID(),
            score: score,
            detail: detail,
            created: Date(),
            name: name,
            avatar: avatar,
            language: language.rawValue
        )
        _ = insert(entry, game: game, rank: rank)
        _ = insert(entry, game: "\(game).\(language.rawValue)", rank: rank)
        return entry.id
    }

    static func label(_ row: ScoreRecord, rank: ScoreRank) -> String {
        switch rank {
        case .high, .low:
            "\(row.score)"
        case .tenths:
            String(format: "%.1f", Double(row.score) / 10)
        case .match:
            "\(row.score) : \(row.detail)"
        case .timed:
            durationLabel(milliseconds: row.detail)
        }
    }

    static func durationLabel(milliseconds: Int) -> String {
        let total = max(0, Double(milliseconds) / 1000)
        let minutes = Int(total) / 60
        let seconds = total - Double(minutes * 60)
        if minutes > 0 {
            return tr(
                ja: String(format: "%d分%.1f秒", minutes, seconds),
                zh: String(format: "%d分%.1f秒", minutes, seconds),
                en: String(format: "%d:%04.1f", minutes, seconds),
                my: String(format: "%d:%04.1f", minutes, seconds),
                ko: String(format: "%d분 %.1f초", minutes, seconds),
                fr: String(format: "%d min %.1f s", minutes, seconds),
                zhHant: String(format: "%d分%.1f秒", minutes, seconds)
            )
        }
        return tr(
            ja: String(format: "%.1f秒", total),
            zh: String(format: "%.1f秒", total),
            en: String(format: "%.1fs", total),
            my: String(format: "%.1fs", total),
            ko: String(format: "%.1f초", total),
            fr: String(format: "%.1f s", total),
            zhHant: String(format: "%.1f秒", total)
        )
    }

    private static func resetStaleBoardsIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: generationKey) < generation else { return }
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("scoreboard.") && key != generationKey {
            defaults.removeObject(forKey: key)
        }
        defaults.set(generation, forKey: generationKey)
    }

    private static func stored(for game: String) -> [ScoreRecord] {
        guard let data = UserDefaults.standard.data(forKey: key(game)),
              let rows = try? JSONDecoder().decode([ScoreRecord].self, from: data) else {
            return []
        }
        return rows
    }

    private static func insert(_ entry: ScoreRecord, game: String, rank: ScoreRank) -> Bool {
        var rows = stored(for: game)
        rows.append(entry)
        rows.sort { better($0, than: $1, rank: rank) }
        if let data = try? JSONEncoder().encode(rows) {
            UserDefaults.standard.set(data, forKey: key(game))
        }
        return true
    }

    private static func better(_ first: ScoreRecord, than second: ScoreRecord, rank: ScoreRank) -> Bool {
        switch rank {
        case .high:
            if first.score != second.score { return first.score > second.score }
        case .low, .tenths:
            if first.score != second.score { return first.score < second.score }
        case .match, .timed:
            if first.score != second.score { return first.score > second.score }
            if first.detail != second.detail { return first.detail < second.detail }
        }
        return first.created < second.created
    }

    private static func key(_ game: String) -> String {
        "scoreboard.\(game)"
    }
}

struct ScoreBoardFilterBar: View {
    @Binding var filter: ScoreBoardFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(.all, tr(ja: "総合", zh: "总榜", en: "All", my: "အားလုံး"))
                ForEach(AppLanguage.allCases) { language in
                    chip(.language(language), language.label)
                }
            }
        }
        .accessibilityIdentifier("stroop-rank-filter")
    }

    private func chip(_ value: ScoreBoardFilter, _ title: String) -> some View {
        let selected = filter == value
        return Button {
            filter = value
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(selected ? CatQuizPalette.ink : CatQuizPalette.wood)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    Capsule().fill(
                        selected
                            ? Color(red: 0.98, green: 0.74, blue: 0.32)
                            : CatQuizPalette.cream
                    )
                }
                .overlay {
                    Capsule().strokeBorder(CatQuizPalette.wood.opacity(selected ? 0.45 : 0.16), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct ScoreBoardList: View {
    let game: String
    var rank: ScoreRank = .high
    var filter: ScoreBoardFilter = .all
    var title: String?
    var textColor: Color = .white
    @ObservedObject private var languages = LanguageStore.shared

    var body: some View {
        let _ = languages.language
        let rows = ScoreBoard.records(for: game, filter: filter)
        VStack(alignment: .leading, spacing: 6) {
            Text(title ?? tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း"))
                .font(.headline)
                .foregroundStyle(textColor)
            if rows.isEmpty {
                Text(tr(ja: "まだ記録がない", zh: "还没有记录", en: "No scores yet", my: "မှတ်တမ်းမရှိသေးပါ"))
                    .font(.caption)
                    .foregroundStyle(textColor.opacity(0.62))
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .frame(width: 22, alignment: .leading)
                            if !row.avatar.isEmpty {
                                Text(row.avatar)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                if !row.name.isEmpty {
                                    Text(row.name)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Text(ScoreBoard.label(row, rank: rank))
                                    .monospacedDigit()
                            }
                            Spacer(minLength: 0)
                            if rank == .timed {
                                Text(tr(ja: "\(row.score)点", zh: "\(row.score)分", en: "\(row.score) pts", my: "\(row.score)", ko: "\(row.score)点", fr: "\(row.score) pts", zhHant: "\(row.score)分"))
                                    .monospacedDigit()
                                    .opacity(0.72)
                            }
                        }
                        .font(.subheadline.weight(index == 0 ? .bold : .regular))
                        .foregroundStyle(textColor.opacity(index == 0 ? 1 : 0.78))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
