# AI 地牢冒险 (AI Dungeon Lite) — 设计文档

## 概述

一款 iOS (iPhone/iPad) Roguelike 地牢冒险游戏，核心特色是多种 AI 互动方式：LLM 驱动的 NPC 对话、AI 策略怪物战斗、AI 动态生成地牢内容。面向游戏开发入门学习，1-2 周开发周期。

## 目标用户

开发者自己（学习 iOS 游戏开发 + AI 集成）

## 技术前提

- 开发者有 Swift/SwiftUI 经验，游戏开发新手
- 目标平台：iOS (iPhone 竖屏为主，iPad 分栏适配)

---

## 核心玩法循环 (Gameplay Loop)

### 一次游戏流程

1. **选择角色** — 战士/法师/盗贼，每种有不同属性和技能
2. **进入地牢** — AI 生成本层地牢主题（废弃矿洞、幽灵城堡、地下森林等）
3. **探索房间** — 5x5 网格地牢，点击相邻格子移动
4. **触发事件** — 每个房间触发一种事件：
   - 怪物战斗（AI 策略对手）
   - NPC 对话（LLM 驱动）
   - 宝箱/陷阱（随机奖惩）
   - Boss 房（地牢终点）
5. **死亡或通关** — 展示本次统计，重新开始（无存档）

### 地图可见性

- 迷雾系统：只能看到已探索的房间和相邻房间

---

## 战斗系统

### 属性体系

- HP / ATK / DEF 三属性
- 玩家和怪物共用同一套属性

### 玩家动作（每回合选一个）

- **攻击** — 伤害 = ATK - 敌方 DEF
- **防御** — 本回合受到伤害减半
- **技能** — 每角色 2 个特殊技能
  - 战士：重击、嘲讽
  - 法师：火球、治愈
  - 盗贼：偷窃、毒刃
- **使用道具** — 药水、卷轴等

### 怪物 AI 策略（本地 GameplayKit）

不通过 LLM，用本地决策树/状态机，零延迟响应：

- **近战型** — 优先攻击，低血量时狂暴（ATK 翻倍）
- **远程型** — 保持距离，优先技能攻击
- **Boss** — 多阶段，血量阈值触发新技能和行为模式

### 战斗结算

- 胜利：获得经验值 + 随机掉落（AI 生成物品名和描述）
- 死亡：游戏结束

---

## NPC 对话系统

### LLM 驱动

- 每层地牢 1-2 个 NPC 房间
- 进入时 AI 生成 NPC 的名字、外貌、性格、背景
- 玩家通过文字输入自由对话

### System Prompt 结构

```
你是 {NPC名字}，{职业}，{性格描述}。
你所在的地牢主题是 {主题}。
玩家当前状态：HP {x}/{max}, 持有物品 {items}。
你的行为规则：
- 保持角色扮演，不要出戏
- 可以提供本层地牢的线索（Boss 弱点、隐藏房间等）
- 可以提供交易（用金币换道具）
- 不能直接帮玩家战斗
```

### 结构化输出

AI 回复中包含结构化标记，客户端解析执行：

- `[TRADE: 生命药水, 50金币]` → 弹出交易确认
- `[HINT: Boss弱火属性]` → 记录到玩家笔记
- `[GIFT: 神秘钥匙]` → 物品进背包

使用 JSON mode / tool use 保证输出格式可控。

### 对话 UI

- SwiftUI 聊天气泡界面，底部输入框
- 流式显示（逐字出现）
- 对话历史保留在本次房间访问中，离开房间后清除

---

## AI 后端设计

### 统一接口层

抽象 `AIProvider` 协议，所有 LLM 调用通过统一接口。

### 支持的 Provider

- **Ollama** — 本地运行，免费，开发调试用
- **OpenAI** — GPT 系列
- **OpenAI 兼容 API** — DeepSeek、Groq、Together AI、本地 vLLM 等

### 实现策略

所有 Provider 本质上共用一套 OpenAI 兼容的 HTTP client（`/v1/chat/completions`），只需切换 base URL、API Key 和模型名。一套代码覆盖所有 Provider。

### 设置页面

- 选择 Provider 类型（Ollama / OpenAI / OpenAI 兼容）
- 填入 API Base URL + API Key（Ollama 只需 URL）
- 选择/输入模型名称
- 一键"测试连接"

### 离线降级

AI 不可用时，用预设模板文本兜底（固定房间描述、NPC 固定对话），保证游戏可玩。

---

## 技术架构

### 项目结构

```
AIDungeon/
├── App/                        # App 入口、路由
├── Models/                     # 数据模型
│   ├── Player.swift            # 玩家属性、背包
│   ├── Monster.swift           # 怪物属性、行为类型
│   ├── Room.swift              # 房间类型、事件
│   └── Dungeon.swift           # 地牢网格、迷雾状态
├── Views/                      # SwiftUI 视图
│   ├── DungeonMapView.swift    # 5x5 网格地图
│   ├── BattleView.swift        # 战斗界面
│   ├── ChatView.swift          # NPC 对话
│   ├── InventoryView.swift     # 背包
│   └── SettingsView.swift      # AI Provider 配置
├── Game/                       # 游戏逻辑
│   ├── GameEngine.swift        # 核心状态机
│   ├── BattleEngine.swift      # 战斗逻辑
│   └── MonsterAI.swift         # GameplayKit 怪物策略
├── AI/                         # AI 层
│   ├── AIProvider.swift        # 协议定义
│   ├── OpenAIClient.swift      # OpenAI 兼容 client
│   ├── PromptBuilder.swift     # System prompt 组装
│   └── ResponseParser.swift    # 解析结构化标记
└── Resources/                  # 降级模板文本、像素素材
```

### 技术选型

| 层面 | 选择 | 理由 |
|------|------|------|
| UI 框架 | SwiftUI | 已熟悉，对话/菜单/设置天然适合 |
| 游戏渲染 | SpriteKit | 地图和战斗动画，通过 `SpriteView` 嵌入 SwiftUI |
| 怪物 AI | GameplayKit | Apple 原生，决策树/状态机开箱即用 |
| 网络层 | URLSession + async/await | 原生够用，无第三方依赖 |
| 数据持久化 | UserDefaults + Codable | 设置存储；Roguelike 不需要存档 |
| LLM 流式响应 | AsyncSequence | 处理 SSE 流式输出 |

### 适配

- iPhone：竖屏为主布局
- iPad：利用大屏，地图和对话左右分栏

---

## 开发阶段规划

### Phase 1 (Day 1-3): 基础框架

- Xcode 项目搭建、基本导航结构
- 数据模型定义（Player, Monster, Room, Dungeon）
- 5x5 地图渲染 + 迷雾系统 + 玩家移动

### Phase 2 (Day 4-6): 战斗系统

- BattleEngine 回合制逻辑
- GameplayKit 怪物 AI 策略
- 战斗 UI（HP 条、动作按钮、动画）

### Phase 3 (Day 7-9): AI 集成

- AIProvider 协议 + OpenAI 兼容 client
- 设置页面（Provider 选择、URL/Key 配置、连接测试）
- 地牢主题生成、房间描述生成
- 离线降级模板

### Phase 4 (Day 10-12): NPC 对话

- ChatView 聊天界面 + 流式显示
- PromptBuilder 动态组装上下文
- ResponseParser 解析交易/线索/赠礼标记
- NPC 交互功能（交易、线索记录）

### Phase 5 (Day 13-14): 打磨

- 角色选择界面
- 背包系统
- Boss 战多阶段逻辑
- iPad 分栏适配
- 整体测试和 bug 修复

### 最小可玩版本

Phase 1-3 完成后即可试玩：地图移动、打怪、AI 生成房间描述。后续 Phase 增量添加。
