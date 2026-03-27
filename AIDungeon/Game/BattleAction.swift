import Foundation

enum BattleAction {
    case attack
    case defend
    case skill(Skill)
    case useItem(Item)
}
