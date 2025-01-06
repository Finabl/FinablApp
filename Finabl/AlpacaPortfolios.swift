//
//  AlpacaPortfolios.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/3/25.
//

import SwiftUI

// Data structure for AlpacaPortfolios
struct AlpacaPortfolio: Identifiable {
    var id = UUID()
    var name: String
    var balance: Double
    var growth: Double
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
                        HStack(spacing: 10) {
                            // Chart placeholder
                            Rectangle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(portfolio.name)
                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                Text("$\(String(format: "%.2f", portfolio.balance))")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                Text("\(portfolio.growth > 0 ? "+" : "")\(String(format: "%.2f", portfolio.growth))%")
                                    .font(Font.custom("Anuphan-Regular", size: 12))
                                    .foregroundColor(portfolio.growth >= 0 ? .green : .red)
                            }
                            Spacer()
                        }
                        .padding()
                        //.background(.secondary)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
        
    }
}
#Preview {
    AlpacaPortfolioListView(portfolios: [
        AlpacaPortfolio(name: "Portfolio A", balance: 1000.00, growth: 5.0),
        AlpacaPortfolio(name: "Portfolio B", balance: 1500.00, growth: 2.5),
        AlpacaPortfolio(name: "Portfolio C", balance: 750.00, growth: -1.2)
    ])
}


