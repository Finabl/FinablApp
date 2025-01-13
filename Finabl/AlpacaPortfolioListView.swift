//
//  AlpacaPortfolios.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/3/25.
//

import SwiftUI

struct RootResponse: Codable {
    let message: String
    let portfolios: [AlpacaPortfolio]
}

// Root Portfolio Struct
struct AlpacaPortfolio: Codable, Identifiable {
    var id: String { portfolioId } // Conforming to Identifiable
    let portfolioId: String // Unique Portfolio ID
    let portfolioName: String // Name of the portfolio
    let usernames: [String] // Multiple users with access
    let alpacaId: String // Owner's Alpaca ID
    let stockAllocation: [StockAllocation] // Target allocation
    let stocks: [Stock] // Actual stocks held
    let transactions: [Transaction] // Transaction history
}

// Stock Allocation and Held Stocks
struct StockAllocation: Codable {
    let ticker: String // Stock ticker symbol
    let percentage: Double? // Allocation percentage
    let shares: Int // Number of shares held
}

// Actual Stocks Held
struct Stock: Codable {
    let ticker: String // Stock ticker symbol
    let shares: Int // Number of shares held
}

// Transaction History
struct Transaction: Codable {
    let id: String // Alpaca transaction ID
    let shares: Int // Number of shares traded
    let ticker: String // Stock ticker symbol
    let dollarAmount: Double // Dollar amount of the transaction
    let datetime: String // Date and time of the transaction
    let type: String // Transaction type: "buy" or "sell"
}

struct AlpacaPortfolioListView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the current view
    
    var portfolios: [AlpacaPortfolio]
    
    var body: some View {
        VStack(spacing: 1) {
            // Custom Top Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Go back to HomeView
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Portfolios")
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    // Future action for settings
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(UIColor.systemBackground))
            
            // Search Bar
            HStack {
                TextField("Search", text: .constant(""))
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                Button(action: {
                    // Sorting action
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            
            // Create New Button
            HStack {
                NavigationLink(destination: PortfolioGenerationView()) {
                    Text("Create new")
                        .font(Font.custom("Anuphan-Bold", size: 14))
                        .foregroundColor(.blue)
                        .padding(.leading)
                }
                Spacer()
                Button(action: {
                    // Create new action
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            
            // Portfolio Cards
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(portfolios) { portfolio in
                        NavigationLink(destination: AlpacaPortfolioSpecificView(portfolio: portfolio).navigationBarBackButtonHidden()) {
                            HStack(spacing: 10) {
                                // Chart placeholder
                                Rectangle()
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(portfolio.portfolioName)
                                        .font(Font.custom("Anuphan-Bold", size: 16))
                                        .foregroundStyle(.primary)
                                    //Text("$\(String(format: "%.2f", portfolio.balance))")
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundStyle(.secondary)
                                    //Text("\(portfolio.growth > 0 ? "+" : "")\(String(format: "%.2f", portfolio.growth))%")
                                       // .font(Font.custom("Anuphan-Regular", size: 12))
                                        //.foregroundColor(portfolio.growth >= 0 ? .green : .red)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.top)
            }
        }
    }
}

#Preview {
    AlpacaPortfolioListView(portfolios: [
        AlpacaPortfolio(
            portfolioId: "uuid1",
            portfolioName: "Tech Stocks",
            usernames: ["user1@example.com", "user2@example.com"],
            alpacaId: "alpaca123",
            stockAllocation: [
                StockAllocation(ticker: "AAPL", percentage: 0.5, shares: 10),
                StockAllocation(ticker: "MSFT", percentage: 0.3, shares: 15),
                StockAllocation(ticker: "GOOGL", percentage: 0.2, shares: 5)
            ],
            stocks: [
                Stock(ticker: "AAPL", shares: 10),
                Stock(ticker: "MSFT", shares: 15)
            ],
            transactions: [
                Transaction(
                    id: "txn1",
                    shares: 5,
                    ticker: "AAPL",
                    dollarAmount: 750.0,
                    datetime: "2025-01-03T12:00:00Z",
                    type: "buy"
                ),
                Transaction(
                    id: "txn2",
                    shares: 3,
                    ticker: "MSFT",
                    dollarAmount: 500.0,
                    datetime: "2025-01-04T14:00:00Z",
                    type: "sell"
                )
            ]
        )
    ])
}



