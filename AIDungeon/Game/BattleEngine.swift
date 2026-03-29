import Foundation

enum BattleEngine {
    static func executePlayerAction(
        _ action: BattleAction,
        player: inout Player,
        monster: inout Monster
    ) -> BattleResult {
        var damageToMonster = 0
        var damageToPlayer = 0
        var healingDone = 0
        var playerDefending = false
        var playerActionDesc = ""
        var monsterShouldCounterattack = true

        // Tick existing cooldowns at the start of the turn, before any new cooldown is set
        player.tickCooldowns()

        switch action {
        case .attack:
            damageToMonster = monster.stats.takeDamage(raw: player.stats.atk)
            playerActionDesc = "攻击，造成 \(damageToMonster) 点伤害"

        case .defend:
            playerDefending = true
            playerActionDesc = "防御姿态"

        case .skill(let skill):
            if skill.healing > 0 {
                player.stats.heal(skill.healing)
                healingDone = skill.healing
                playerActionDesc = "使用 \(skill.name)，恢复 \(skill.healing) 点生命"
                monsterShouldCounterattack = false
            } else if skill.damage > 0 {
                damageToMonster = monster.stats.takeDamage(raw: skill.damage)
                playerActionDesc = "使用 \(skill.name)，造成 \(damageToMonster) 点伤害"
            } else {
                if skill.id == "heavy_strike" {
                    let rawDamage = Int(Double(player.stats.atk) * 1.5)
                    damageToMonster = monster.stats.takeDamage(raw: rawDamage)
                    playerActionDesc = "重击！造成 \(damageToMonster) 点伤害"
                } else {
                    playerActionDesc = "使用 \(skill.name)"
                }
            }
            player.skillCooldowns[skill.id] = skill.cooldown

        case .useItem(let item):
            switch item.type {
            case .potion:
                player.stats.heal(item.value)
                healingDone = item.value
                player.removeItem(id: item.id)
                playerActionDesc = "使用 \(item.name)，恢复 \(item.value) 点生命"
                monsterShouldCounterattack = false
            case .scroll:
                damageToMonster = monster.stats.takeDamage(raw: item.value)
                player.removeItem(id: item.id)
                playerActionDesc = "使用 \(item.name)，造成 \(damageToMonster) 点伤害"
            default:
                playerActionDesc = "使用 \(item.name)"
            }
        }

        var monsterActionDesc = ""
        if monster.stats.isAlive && monsterShouldCounterattack {
            let defMultiplier = playerDefending ? 2.0 : 1.0
            damageToPlayer = player.stats.takeDamage(raw: monster.stats.atk, defenseMultiplier: defMultiplier)
            monsterActionDesc = "\(monster.name) 攻击，造成 \(damageToPlayer) 点伤害"
        }

        return BattleResult(
            playerAction: playerActionDesc,
            damageToMonster: damageToMonster,
            damageToPlayer: damageToPlayer,
            healingDone: healingDone,
            playerDefending: playerDefending,
            monsterAction: monsterActionDesc,
            monsterDied: !monster.stats.isAlive,
            playerDied: !player.stats.isAlive
        )
    }
}
