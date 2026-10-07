import SwiftUI

enum ScoreRank {
    case high
    case low
    case tenths
    case match
}

struct ScoreRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var score: Int
    var detail: Int
    var created: Date
}

enum ScoreBoard {
    static let limit = 8

    static func records(for game: String) -> [ScoreRecord] {
        guard let data = UserDefaults.standard.data(forKey: key(game)),
              let rows = try? JSONDecoder().decode([ScoreRecord].self, from: data) else {
            return []
        }
        return rows
    }

    @discardableResult
    static func submit(game: String, score: Int, detail: Int = 0, rank: ScoreRank) -> UUID? {
        var rows = records(for: game)
        let entry = ScoreRecord(id: UUID(), score: score, detail: detail, created: Date())
        rows.append(entry)
        rows.sort { better($0, than: $1, rank: rank) }
        let kept = Array(rows.prefix(limit))
        if let data = try? JSONEncoder().encode(kept) {
            UserDefaults.standard.set(data, forKey: key(game))
        }
        return kept.contains(where: { $0.id == entry.id }) ? entry.id : nil
    }

    static func label(_ row: ScoreRecord, rank: ScoreRank) -> String {
        switch rank {
        case .high, .low:
            "\(row.score)"
        case .tenths:
            String(format: "%.1f", Double(row.score) / 10)
        case .match:
            "\(row.score) : \(row.detail)"
        }
    }

    private static func better(_ first: ScoreRecord, than second: ScoreRecord, rank: ScoreRank) -> Bool {
        switch rank {
        case .high:
            if first.score != second.score { return first.score > second.score }
        case .low, .tenths:
            if first.score != second.score { return first.score < second.score }
        case .match:
            if first.score != second.score { return first.score > second.score }
            if first.detail != second.detail { return first.detail < second.detail }
        }
        return first.created < second.created
    }

    private static func key(_ game: String) -> String {
        "scoreboard.\(game)"
    }
}

struct ScoreBoardList: View {
    let game: String
    var rank: ScoreRank = .high
    var title: String?

    var body: some View {
        let rows = ScoreBoard.records(for: game)
        VStack(alignment: .leading, spacing: 6) {
            Text(title ?? tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း"))
                .font(.headline)
                .foregroundStyle(.white)
            if rows.isEmpty {
                Text(tr(ja: "まだ記録がない", zh: "还没有记录", en: "No scores yet", my: "မှတ်တမ်းမရှိသေးပါ"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                            HStack(spacing: 8) {
                                Text("\(index + 1)")
                                    .frame(width: 22, alignment: .leading)
                                Text(ScoreBoard.label(row, rank: rank))
                                    .monospacedDigit()
                                Spacer(minLength: 0)
                            }
                            .font(.subheadline.weight(index == 0 ? .bold : .regular))
                            .foregroundStyle(.white.opacity(index == 0 ? 1 : 0.78))
                        }
                    }
                }
                .frame(maxHeight: min(148, 24 + CGFloat(rows.count) * 24))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
