import SwiftUI

struct ContentView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator
    @State private var showInventory = false

    var body: some View {
        NavigationStack {
            Group {
                switch engine.state {
                case .characterSelect:
                    mainMenu

                case .exploring:
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        HStack(spacing: 0) {
                            DungeonMapView(engine: engine, aiGenerator: aiGenerator)
                                .frame(maxWidth: .infinity)
                            Divider()
                            InventoryView(engine: engine)
                                .frame(width: 300)
                        }
                    } else {
                        DungeonMapView(engine: engine, aiGenerator: aiGenerator)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        showInventory = true
                                    } label: {
                                        Image(systemName: "bag")
                                    }
                                }
                            }
                    }

                case .battle:
                    BattleView(engine: engine)

                case .chat:
                    if let npc = engine.currentNPC {
                        ChatView(
                            engine: engine,
                            aiGenerator: aiGenerator,
                            npcName: npc.name,
                            npcDescription: npc.description,
                            personality: npc.personality
                        )
                    }

                case .gameOver:
                    GameOverView(engine: engine, isVictory: false)

                case .victory:
                    GameOverView(engine: engine, isVictory: true)
                }
            }
            .sheet(isPresented: $showInventory) {
                InventoryView(engine: engine)
            }
        }
    }

    private var mainMenu: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("⚔️ AI 地牢冒险 ⚔️")
                .font(.largeTitle.bold())

            Text("Roguelike × AI")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            CharacterSelectView(engine: engine, aiGenerator: aiGenerator)

            Spacer()

            NavigationLink("⚙️ AI 设置") {
                SettingsView(aiGenerator: aiGenerator)
            }
            .padding(.bottom, 40)
        }
    }
}
