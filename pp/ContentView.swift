import SwiftUI

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var buyIn: Int
    var finishMoney: Int = 0
}

struct BuyInHistory: Identifiable {
    let id = UUID()
    let name: String
    var buyIn: Int
}

struct Winning: Identifiable {
    let id = UUID()
    let name: String
    var winning: Int
}

struct Result: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let amount: Int
}

struct PlayersView: View {
    let players: [Player]
    
    func calculate(players: [Player]) -> [Result]{
        var winnings: [Winning] = []
        for player in players {
            winnings.append(Winning(name: player.name, winning: player.finishMoney - player.buyIn))
        }
        
        var sum = 0
        for winning in winnings {
            sum += winning.winning
        }
        if sum != 0 {
            return []
        }
        
        winnings = winnings.sorted(by: {w1, w2 in w1.winning > w2.winning})
        
        var results: [Result] = []
        
        var l = 0
        var r = winnings.count - 1
        
        while l < r {
            if winnings[l].winning > abs(winnings[r].winning) {
                results.append(
                    Result(
                        from: winnings[r].name, to: winnings[l].name, amount: abs(winnings[r].winning)
                    )
                )
                winnings[l].winning -= abs(winnings[r].winning)
                r -= 1
            } else if winnings[l].winning < abs(winnings[r].winning) {
                results.append(
                    Result(
                        from: winnings[r].name, to: winnings[l].name, amount: winnings[l].winning
                    )
                )
                winnings[r].winning += winnings[l].winning
                l += 1
            } else {
                results.append(
                    Result(
                        from: winnings[r].name, to: winnings[l].name, amount: winnings[l].winning
                    )
                )
                r -= 1
                l += 1
            }
        }
        return results
    }
    
    var body: some View {
        let ending: [Result] = calculate(players: players)
        
        List {
            if ending.isEmpty {
              Text("Sum doesn't add up!") // Displayed if ending list is empty
            } else {
              ForEach(ending) { ending in
                Text("\(ending.from) -> \(ending.to) \(ending.amount)")
              }
            }
          }
    }
}

struct HistoryView: View {
    let history: [BuyInHistory]
    
    var body: some View {
        List {
            if history.isEmpty {
              Text("No players!") // Displayed if ending list is empty
            } else {
              ForEach(history) { buyInHistory in
                Text("\(buyInHistory.name) bought in \(buyInHistory.buyIn)")
              }
            }
          }
    }
}

struct ContentView: View {
    @State private var players: [Player] = []
    @State private var history: [BuyInHistory] = []
    @State private var name = ""
    @State private var buyIn = 0
    @State private var money = 0
    @State private var finishMoney = 0
    @State private var selectedPlayer: Player? = nil
    @State private var isFinish = false
    @State private var isHistory = false
    @State private var bankSum: Int = 0
    
    func refreshPlayer(player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(players) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text("Buy-In: \(player.buyIn)")
                            Text("End \(player.finishMoney)")
                        }.onTapGesture {
                            selectedPlayer = player
                        }
                    }
                }
                
                VStack {
                    Text("Bank sum: \(bankSum)")
                }
                
                Button("History") {
                    isHistory.toggle()
                }
                if isHistory {
                    HistoryView(history: history)
                }
                
                Button("Finish the game") {
                    isFinish.toggle()
                }
                if isFinish {
                    PlayersView(players: players)
                }
                
                HStack {
                    TextField("Player Name", text: $name)
                    TextField("Buy-In Amount", value: $buyIn, format: .number)
                        .keyboardType(.numberPad)
                    Button("Add Player") {
                        if !name.isEmpty && buyIn > 0 {
                            players.append(Player(name: name, buyIn: buyIn))
                            history.append(BuyInHistory(name: name, buyIn: buyIn))
                            bankSum = bankSum + buyIn
                            name = ""
                            buyIn = 0
                        }
                    }
                }
                if selectedPlayer != nil {
                    HStack {
                        TextField("Rebuy Amount", value: $money, format: .number)
                            .keyboardType(.numberPad)
                            .disabled(selectedPlayer == nil)
                        Button("Rebuy") {
                            if money > 0 {
                                selectedPlayer!.buyIn = selectedPlayer!.buyIn + money
                                bankSum = bankSum + selectedPlayer!.buyIn
                                history.append(
                                    BuyInHistory(name: selectedPlayer!.name, buyIn: selectedPlayer!.buyIn)
                                )
                                refreshPlayer(player: selectedPlayer!)
                                money = 0
                                selectedPlayer = nil
                            }
                        }
                        Button("Finish"){
                            selectedPlayer!.finishMoney = money
                            refreshPlayer(player: selectedPlayer!)
                            money = 0
                            selectedPlayer = nil
                        }
                    }
                }
            }
            .navigationTitle("Home Poker Game Calculator")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
