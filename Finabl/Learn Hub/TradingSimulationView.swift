//
//  TradingSimulationView.swift
//  Finabl
//
//  Created by Ishaan Masilamony on 2/8/25.
//

import SwiftUI
import Charts

extension Array where Element: CodingKey {
    var pathDescription: String {
        map { $0.stringValue }.joined(separator: " → ")
    }
}

struct StockData: Decodable, Identifiable, Hashable {
    let ticker: String
    let shares: Float
    var id: String {ticker}
    
    private enum CodingKeys: String, CodingKey {
        case ticker, shares
    }
}

struct StockPrice: Decodable, Hashable, Identifiable {
    let timestamp: Date
    let price: Double
    var id: Date {timestamp}
    
    private enum CodingKeys: String, CodingKey {
        case timestamp = "datetime"
        case price = "closePrice"
    }
}

struct StockHistory: Decodable, Hashable {
    let ticker: String
    let priceHistory: [StockPrice]
    
    private enum CodingKeys: String, CodingKey {
        case ticker, priceHistory
    }
}

struct PortfolioData: Decodable, Identifiable, Hashable {
let name: String
let id: String
    let stocks: [StockData]
    
    private enum CodingKeys: String, CodingKey {
        case name = "portfolioName"
        case id = "portfolioId"
        case stocks
    }
}

struct TradingSimulationView: View {
    @State private var portfolios: [PortfolioData] = []
    @State private var selectedPortfolio: PortfolioData?
    @State private var selectedStock: StockData?
    @State private var stockHistory: StockHistory?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try parsing with fractional seconds first [1][7]
            let formatterWithFraction = ISO8601DateFormatter()
            formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // Fallback to standard format if needed [3][19]
            let formatterStandard = ISO8601DateFormatter()
            formatterStandard.formatOptions = [.withInternetDateTime]
            
            if let date = formatterWithFraction.date(from: dateString) {
                return date
            } else if let date = formatterStandard.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return decoder
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else if let error = errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        portfolioSelectionView
                        stockSelectionView
                        historyChart
                    }
                }
                .task {
                    await fetchPortfolio(portfolioID:"2af550d0-58fe-4181-96fc-cfd9071014cb")
                }
                .padding()
                .navigationTitle("Trading Simulator")
                // Add more trading components here
                .padding()
            }

        }
    }
    
    private var tradeView: some View {
        Group {
            
        }
    }
    
    private var portfolioSelectionView: some View {
        Picker("Portfolio", selection: $selectedPortfolio) {
            Text("Select Portfolio").tag(nil as PortfolioData?)
            ForEach(portfolios) { portfolio in
                Text(portfolio.name).tag(portfolio as PortfolioData?)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedPortfolio) { oldValue, newValue in
            selectedStock = nil
            stockHistory = nil
            guard newValue != nil else { return }
        }
    }
        
    private var stockSelectionView: some View {
        Group {
                if let portfolio = selectedPortfolio {
                    Picker("Stock", selection: $selectedStock) {
                        Text("Select Stock").tag(nil as StockData?)
                        ForEach(portfolio.stocks) { stock in
                            Text("\(stock.ticker) (\(stock.shares))")
                                .tag(stock as StockData?)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedStock) { oldValue, newValue in
                        guard let stock = newValue else { return }
                        Task {
                            print(stock.ticker)
                            await fetchStockHistory(ticker: stock.ticker)
                        }
                    }
                }
            }
    }
        
    private var historyChart: some View {
        Group {
            if let history = stockHistory, !history.priceHistory.isEmpty {
                Chart {
                    ForEach(history.priceHistory) { price in
                        // Add an area fill under the line for a shadow effect:
                        AreaMark(
                            x: .value("Date", price.timestamp, unit: .day),
                            y: .value("Price", price.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.4), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.monotone)
                        
                        // Draw a smooth line over the area:
                        LineMark(
                            x: .value("Date", price.timestamp, unit: .day),
                            y: .value("Price", price.price)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                        .foregroundStyle(Color.green)
                        .interpolationMethod(.monotone)
                    }
                }
                // Customize the X-axis with grid lines and date labels:
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        if let _ = value.as(Date.self) {
                            AxisValueLabel(format: .dateTime.day().month(.narrow))
                        }
                    }
                }
                // Customize the Y-axis to display prices with a currency format:
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        if let priceValue = value.as(Double.self) {
                            AxisValueLabel {
                                Text("$\(String(format: "%.2f", priceValue))")
                            }
                        }
                    }
                }
                .frame(height: 250)
                .padding(.horizontal)
            }
        }
    }

    
    func fetchPortfolio(portfolioID: String) async {
            do {
                let url = URL(string: "http://app.finabl.org/api/portfolios/2af550d0-58fe-4181-96fc-cfd9071014cb?email=mehdihdev@gmail.com")!
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                
                switch httpResponse.statusCode {
                case 200:
                    let portfolio = try decoder.decode(PortfolioData.self, from: data)
                    updateOrAddPortfolio(portfolio)
                    
                case 404:
                    errorMessage = "Portfolio not found"
                case 400...499:
                    errorMessage = "Client error: \(httpResponse.statusCode)"
                case 500...599:
                    errorMessage = "Server error: \(httpResponse.statusCode)"
                default:
                    errorMessage = "Unexpected response: \(httpResponse.statusCode)"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
    private func updateOrAddPortfolio(_ portfolio: PortfolioData) {
        if let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            portfolios[index] = portfolio
        } else {
            portfolios.append(portfolio)
        }
    }
    
    // Error handler function [3][10]
    private func handleDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return """
            Missing key: \(key.stringValue)
            """
        case .typeMismatch(let type, let context):
            return """
            Type mismatch: \(type)
            """
        case .valueNotFound(let type, let context):
            return """
            Missing value: \(type)
            """
        @unknown default:
            return "Unknown decoding error"
        }
    }
    
    private func fetchStockHistory(ticker: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let urlString = "http://app.finabl.org/api/portfolios/stock-history?ticker=\(ticker)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "HTTP Error: \(response)"
                return
            }
            
            let prices = try decoder.decode([StockPrice].self, from: data)
            stockHistory = StockHistory(ticker: ticker, priceHistory: prices)
            
        } catch let decodingError as DecodingError {
            errorMessage = handleDecodingError(decodingError)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    TradingSimulationView()
}
