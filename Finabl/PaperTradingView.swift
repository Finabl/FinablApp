/*//
//  PaperTradingView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/30/25.
//

import SwiftUI
import Charts
import Combine

// Alpaca API Credentials
let alpacaApiKey = "PKIVIWV8GF6IJEOCQ1DO"
let alpacaSecretKey = "gZyVMmwydhhUnmYdpPfc71lK8TR4mioryf11OrEj"
let alpacaBaseURL = "https://paper-api.alpaca.markets/v2/"
let alpacaWebSocketURL = "wss://stream.data.alpaca.markets/v2/test" // Use sandbox for testing

// Model for a trade
struct Trade: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let quantity: Int
    let type: String // "BUY" or "SELL"
    let timestamp: Date
}

// Data model for portfolio value tracking
struct PortfolioValue: Identifiable {
    let id = UUID()
    let time: Date
    let value: Double
}

// WebSocket Manager for real-time stock price updates
class AlpacaWebSocketManager: ObservableObject {
    @Published var stockPrices: [String: Double] = [:]
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var isAuthenticated = false
    private var symbols: [String] = []
    weak var simulator: PaperTradingSimulator?

    func connect(symbols: [String]) {
        disconnect()
        self.symbols = symbols

        guard let url = URL(string: alpacaWebSocketURL) else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()

        authenticate { success in
            if success {
                print("✅ WebSocket Authentication Successful!")
                self.subscribeToStocks()
                self.receiveMessages()
            } else {
                print("❌ WebSocket Authentication Failed!")
            }
        }
    }

    private func authenticate(completion: @escaping (Bool) -> Void) {
        let authMessage: [String: Any] = [
            "action": "auth",
            "key": alpacaApiKey,
            "secret": alpacaSecretKey
        ]
        sendMessage(authMessage) { success in
            if success {
                self.isConnected = true
                self.isAuthenticated = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    private func subscribeToStocks() {
        guard isConnected, isAuthenticated else {
            print("⚠️ WebSocket not connected or authenticated, cannot subscribe.")
            return
        }

        let subscribeMessage: [String: Any] = [
            "action": "subscribe",
            "trades": symbols,
            "quotes": symbols,
            "bars": symbols
        ]
        sendMessage(subscribeMessage, completion: nil)
    }

    private func sendMessage(_ message: [String: Any], completion: ((Bool) -> Void)?) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else { return }
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📩 Sending WebSocket Message: \(jsonString)")
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ WebSocket send error: \(error)")
                    completion?(false)
                } else {
                    completion?(true)
                }
            }
        }
    }

    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    print("🔹 Received WebSocket Message: \(text)")

                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        
                        for update in json {
                            if update["T"] as? String == "q",
                               let symbol = update["S"] as? String,
                               let price = update["bp"] as? Double {
                                DispatchQueue.main.async {
                                    self?.stockPrices[symbol] = price
                                    self?.simulator?.updatePortfolioValue()
                                }
                            } else if update["T"] as? String == "t",
                                      let symbol = update["S"] as? String,
                                      let price = update["p"] as? Double {
                                DispatchQueue.main.async {
                                    self?.stockPrices[symbol] = price
                                    self?.simulator?.updatePortfolioValue()
                                }
                            }
                        }
                    }
                }
                self?.receiveMessages()
            case .failure(let error):
                print("❌ WebSocket error: \(error)")
                //self?.reconnect()
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        isAuthenticated = false
    }
}

// Portfolio Manager
class PaperTradingSimulator: ObservableObject {
    @Published var balance: Double = 10000
    @Published var portfolio: [String: (quantity: Int, avgPrice: Double)] = [:]
    @Published var transactionHistory: [Trade] = []
    @Published var portfolioHistory: [PortfolioValue] = []

    private var webSocketManager: AlpacaWebSocketManager

    init(webSocketManager: AlpacaWebSocketManager) {
        self.webSocketManager = webSocketManager
        self.webSocketManager.simulator = self
        self.portfolioHistory.append(PortfolioValue(time: Date(), value: balance))
    }

    func updatePortfolioValue() {
        DispatchQueue.main.async {
            var totalStockValue: Double = 0
            for (symbol, position) in self.portfolio {
                if let livePrice = self.webSocketManager.stockPrices[symbol] {
                    totalStockValue += Double(position.quantity) * livePrice
                }
            }

            let totalValue = self.balance + totalStockValue
            self.portfolioHistory.append(PortfolioValue(time: Date(), value: totalValue))

            self.objectWillChange.send()
            print("📈 Portfolio Updated: \(totalValue)")
        }
    }

    func buyStock(symbol: String, quantity: Int) {
        DispatchQueue.main.async {
            if let price = self.webSocketManager.stockPrices[symbol] {
                let cost = Double(quantity) * price
                if self.balance >= cost {
                    self.balance -= cost
                    self.portfolio[symbol, default: (0, price)] = (self.portfolio[symbol]?.quantity ?? 0 + quantity, price)
                    self.transactionHistory.append(Trade(symbol: symbol, price: price, quantity: quantity, type: "BUY", timestamp: Date()))

                    self.updatePortfolioValue()
                    print("✅ Bought \(quantity) shares of \(symbol) at $\(price). New Balance: \(self.balance)")
                }
            }
        }
    }
}

// SwiftUI View with Buy/Sell Options
struct PaperTradingView: View {
    @StateObject private var webSocketManager = AlpacaWebSocketManager()
    @StateObject private var simulator: PaperTradingSimulator

    @State private var symbol: String = "AAPL"
    @State private var quantity: String = "1"

    init() {
        let webSocketManager = AlpacaWebSocketManager()
        _simulator = StateObject(wrappedValue: PaperTradingSimulator(webSocketManager: webSocketManager))
    }

    var body: some View {
        VStack {
            Text("Alpaca Paper Trading")
                .font(.largeTitle)
                .padding()

            Text("Balance: $\(simulator.balance, specifier: "%.2f")")
                .font(.title2)
                .padding()

            HStack {
                TextField("Symbol", text: $symbol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Quantity", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Buy") {
                    if let qty = Int(quantity) {
                        simulator.buyStock(symbol: symbol.uppercased(), quantity: qty)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear { webSocketManager.connect(symbols: ["FAKEPACA"]) }
        .onDisappear { webSocketManager.disconnect() }
    }
}

#Preview { PaperTradingView() }
*/
