//
//  TradingSimulatorView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/30/25.
//

import SwiftUI
import Combine
import Foundation

struct Trade: Identifiable {
    let id = UUID()
    let type: String // Buy or Sell
    let quantity: Int
    let price: Double
    let date: Date
}

class TradingViewModel: ObservableObject {
    @Published var balance: Double = 10000.0
    @Published var holdings: Int = 0
    @Published var stockPrice: Double = 100.0
    @Published var transactions: [Trade] = []
    @Published var portfolioHistory: [(Date, Double)] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let apiKey = "PKIVIWV8GF6IJEOCQ1DO"
    private let apiSecret = "gZyVMmwydhhUnmYdpPfc71lK8TR4mioryf11OrEj"
    
    init() {
        connectWebSocket()
    }
    
    func connectWebSocket() {
        var request = URLRequest(url: URL(string: "wss://stream.data.alpaca.markets/v2/test")!)
        request.addValue(apiKey, forHTTPHeaderField: "APCA-API-KEY-ID")
        request.addValue(apiSecret, forHTTPHeaderField: "APCA-API-SECRET-KEY")
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        sendSubscriptionMessage()
        receiveData()
    }
    
    func sendSubscriptionMessage() {
        let subscriptionMessage = [
            "action": "subscribe",
            "quotes": ["FAKEPACA"]
        ] as [String : Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: subscriptionMessage, options: [])
            webSocketTask?.send(.data(data)) { error in
                if let error = error {
                    print("WebSocket subscription error: \(error)")
                }
            }
        } catch {
            print("Failed to encode subscription message: \(error)")
        }
    }
    
    func receiveData() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        if let data = text.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                           let quote = json.first,
                           let price = quote["ap"] as? Double {
                            self?.stockPrice = price
                        }
                    }
                default: break
                }
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
            self?.receiveData()
        }
    }
    
    func buyStock(quantity: Int) {
        let cost = stockPrice * Double(quantity)
        guard balance >= cost else { return }
        balance -= cost
        holdings += quantity
        let trade = Trade(type: "Buy", quantity: quantity, price: stockPrice, date: Date())
        transactions.append(trade)
        updatePortfolioHistory()
    }
    
    func sellStock(quantity: Int) {
        guard holdings >= quantity else { return }
        let revenue = stockPrice * Double(quantity)
        balance += revenue
        holdings -= quantity
        let trade = Trade(type: "Sell", quantity: quantity, price: stockPrice, date: Date())
        transactions.append(trade)
        updatePortfolioHistory()
    }
    
    func updatePortfolioHistory() {
        let totalValue = balance + (Double(holdings) * stockPrice)
        portfolioHistory.append((Date(), totalValue))
    }
}

struct PortfolioChart: View {
    let data: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard data.count > 1 else { return }
                let maxValue = data.map { $0.1 }.max() ?? 1
                let minValue = data.map { $0.1 }.min() ?? 0
                let width = geometry.size.width
                let height = geometry.size.height
                
                let points = data.enumerated().map { (index, entry) -> CGPoint in
                    let x = CGFloat(index) / CGFloat(data.count - 1) * width
                    let y = height - ((entry.1 - minValue) / (maxValue - minValue) * height)
                    return CGPoint(x: x, y: y)
                }
                
                if let firstPoint = points.first {
                    path.move(to: firstPoint)
                    points.forEach { path.addLine(to: $0) }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}


struct TradingSimulatorView: View {
    @StateObject private var viewModel = TradingViewModel()
    @State private var quantity: String = ""
    
    var body: some View {
        VStack {
            Text("Trading Simulator").font(.largeTitle)
            
            Text("Balance: $\(viewModel.balance, specifier: "%.2f")")
            Text("Holdings: \(viewModel.holdings) FAKEPACA")
            Text("Current Price: $\(viewModel.stockPrice, specifier: "%.2f")")
            
            HStack {
                TextField("Quantity", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Button("Buy") {
                    if let qty = Int(quantity) {
                        viewModel.buyStock(quantity: qty)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Sell") {
                    if let qty = Int(quantity) {
                        viewModel.sellStock(quantity: qty)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            PortfolioChart(data: viewModel.portfolioHistory)
                .frame(height: 200)
                .padding()
            
            List(viewModel.transactions) { trade in
                HStack {
                    Text(trade.type)
                        .foregroundColor(trade.type == "Buy" ? .green : .red)
                    Text("\(trade.quantity) @ $\(trade.price, specifier: "%.2f")")
                    Spacer()
                    Text(trade.date, style: .date)
                }
            }
        }
        .padding()
    }
}



#Preview {
    TradingSimulatorView()
}
