import Foundation

enum NPCAction {
    case trade(itemName: String, cost: Int)
    case hint(String)
    case gift(itemName: String)
}

struct ParsedResponse {
    let displayText: String
    let actions: [NPCAction]
}

enum ResponseParser {
    private static let tagPattern = /\[(TRADE|HINT|GIFT):\s*([^\]]+)\]/

    static func parse(_ text: String) -> ParsedResponse {
        var actions: [NPCAction] = []
        var displayText = text

        let matches = text.matches(of: tagPattern)
        for match in matches.reversed() {
            let tag = String(match.1)
            let value = String(match.2).trimmingCharacters(in: .whitespaces)

            switch tag {
            case "TRADE":
                let parts = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2, let cost = Int(parts[1].replacingOccurrences(of: "金币", with: "")) {
                    actions.insert(.trade(itemName: parts[0], cost: cost), at: 0)
                }
            case "HINT":
                actions.insert(.hint(value), at: 0)
            case "GIFT":
                actions.insert(.gift(itemName: value), at: 0)
            default:
                break
            }

            displayText = displayText.replacingOccurrences(of: String(match.0), with: "")
        }

        return ParsedResponse(
            displayText: displayText.trimmingCharacters(in: .whitespaces),
            actions: actions
        )
    }
}
