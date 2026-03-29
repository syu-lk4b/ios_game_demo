import Foundation

struct Item: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: ItemType
    let value: Int

    enum ItemType: String, Codable {
        case potion
        case scroll
        case key
        case equipment
        case misc
    }

    static let healthPotion = Item(id: "health_potion", name: "生命药水", description: "恢复30点生命", type: .potion, value: 30)
    static let fireScroll = Item(id: "fire_scroll", name: "火焰卷轴", description: "对敌人造成40点伤害", type: .scroll, value: 40)
}
