import Foundation

enum FallbackContent {
    static let themes = [
        (name: "废弃矿洞", description: "被遗弃已久的矿洞，空气中弥漫着铁锈和潮湿的气息"),
        (name: "幽灵城堡", description: "月光下的古堡，每一面墙壁都在低语"),
        (name: "地下森林", description: "奇异的发光植物照亮了这片地下世界"),
        (name: "冰封神殿", description: "古老的神殿被永恒的寒冰所覆盖"),
        (name: "熔岩洞穴", description: "地面的裂缝中涌出炽热的岩浆")
    ]

    static let roomDescriptions: [String: [String]] = [
        "monster": [
            "阴暗的角落传来低沉的咆哮声。",
            "地面上散落着碎骨，空气中弥漫着危险的气息。",
            "墙壁上的爪痕昭示着这里的主人并不友善。"
        ],
        "npc": [
            "篝火的光芒在墙壁上跳动，一个身影靠在角落。",
            "一个旅者正在这里休息，看到你后微微点头。"
        ],
        "treasure": [
            "房间中央放着一个积满灰尘的箱子。",
            "墙壁的暗格中似乎藏着什么东西。"
        ],
        "trap": [
            "地板上的纹路看起来有些异常...",
            "空气中弥漫着一股奇怪的味道。"
        ],
        "empty": [
            "空荡荡的房间，只有回声作伴。",
            "这里似乎已经被搜刮干净了。",
            "平静的房间，暂时没有危险。"
        ],
        "boss": [
            "巨大的空间，地面上刻满了神秘的符文。远处传来沉重的呼吸声。"
        ]
    ]

    static let npcDialogs = [
        "你好，冒险者。这里很危险，要小心。",
        "想买点什么吗？我这里有些好东西。",
        "你是怎么找到这里的？算了，不重要。",
        "前方的敌人很强，做好准备再去吧。"
    ]

    static func randomTheme() -> (name: String, description: String) {
        themes.randomElement()!
    }

    static func randomRoomDescription(for event: String) -> String {
        (roomDescriptions[event] ?? roomDescriptions["empty"]!).randomElement()!
    }

    static func randomNPCDialog() -> String {
        npcDialogs.randomElement()!
    }
}
