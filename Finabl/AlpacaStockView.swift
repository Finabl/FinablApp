//
//  AlpacaStockView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/16/25.
//

import SwiftUI

struct AlpacaStockView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    var ticker: String
    
    @State private var Selectedtimeframe: String = "1day"
    
    @State private var stockPrice: String = "$0.00"
    @State private var selectedTimeRange: String = "1D"
    @State private var priceChange: String = "0.00"
    @State private var priceChangeColor: Color = .gray
    @State private var priceChangeData: [String: Double] = [:]
    @State private var stockDescription: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    
    @StateObject private var viewModel = NewsViewModel()

    
    
    @State private var lineChartData: [Candlestick] = []
    @State private var isLoading = true
    private let fmpAPI = FMPAPI()
    
    var body: some View {
        // Navigation Header
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Spacer()
            Image(systemName: "ellipsis")
                .font(.title2)
                .foregroundColor(.primary)
        }
        .padding()

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Stock Information
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticker)
                        .font(Font.custom("Anuphan-Bold", size: 24).bold())
                    Text("\(stockPrice)")
                        .font(Font.custom("Anuphan-Bold", size: 32).bold())
                    Text("$\(priceChange)")
                        .font(Font.custom("Anuphan-Medium", size: 16))
                        .foregroundColor(priceChangeColor)
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
                
                ZStack {
                    
                    VStack {
                        if isLoading {
                            Text("Loading data...")
                                .onAppear {
                                    fetchData(timeframe: Selectedtimeframe)
                                    print("hai")
                                }
                        } else if lineChartData.isEmpty {
                            Text("No data available")
                        } else {
                           LineChart(data: lineChartData)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .background(.blue.opacity(0.2))
                                .padding()
                        }
                    }
                }
                

                
                // Time Range Buttons
                HStack(spacing: 16) {
                    ForEach(["1D", "1M", "3M", "1Y", "3Y", "YTD", "Max"], id: \.self) { label in
                        Text(label)
                            .font(Font.custom("Anuphan", size: 14))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(label == selectedTimeRange ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedTimeRange = label
                                updatePriceChange()
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                // Actions
                HStack(spacing: 24) {
                    ActionButton(image: "plus", title: "Add to watchlist")
                    ActionButton(image: "bell", title: "Set notification")
                    ActionButton(image: "rectangle.split.3x3", title: "Compare stocks")
                    ActionButton(image: "chart.xyaxis.line", title: "Create ideograph")
                }
                .padding()
                // Recommendation Heading
                VStack {
                    HStack(spacing: 10) {
                        Image("elephant head")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .background(Color(hex: 0xF3FCFF))
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text("Reccomendation Heading")
                                .font(Font.custom("Anuphan-Medium", size: 18))
                                .foregroundColor(.white)
                            
                            Text("Fin Explains")
                                .font(Font.custom("Anuphan-Regular", size: 14))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(hex: 0x105A90))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                }.padding()
                
                // Your Shares Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your shares")
                        .font(Font.custom("Anuphan", size: 18).bold())
                    HStack {
                        Text(ticker)
                            .font(Font.custom("Anuphan", size: 16))
                        Spacer()
                        Text("+0.00")
                            .font(Font.custom("Anuphan", size: 16))
                            .foregroundColor(.green)
                        Text("$00.00")
                            .font(Font.custom("Anuphan", size: 16))
                    }
                }
                .padding()
                // About Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(Font.custom("Anuphan", size: 18).bold())
                    Text(stockDescription)
                        .lineLimit(5)
                        .font(Font.custom("Anuphan-Medium", size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
                
            }
            
            // News Section
            VStack(alignment: .leading, spacing: 10) {
                Text("News")
                    .font(Font.custom("Anuphan-Bold", size: 18))
                
                ForEach(viewModel.newsArticles) { article in
                    HStack(alignment: .top, spacing: 10) {
                        AsyncImage(url: URL(string: article.image)) { image in
                            image.resizable()
                                 .frame(width: 60, height: 60)
                                 .cornerRadius(8)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(UIColor.systemGray4))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(article.title)
                                .font(Font.custom("Anuphan-SemiBold", size: 14))
                                .lineLimit(2)
                            
                            Text(article.summary)
                                .font(Font.custom("Anuphan-Regular", size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(3)
                            
                            Text(article.timeAgo)
                                .font(Font.custom("Anuphan-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
            .onAppear {
                fetchStockData()
                fetchPriceChangeData()
                viewModel.fetchNews(tickers: ticker)
            }
            
        }
    }
    private func fetchData(timeframe: String) {
        fmpAPI.fetchLineChartData(symbol: "AAPL", timeframe: timeframe) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.lineChartData = data
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func fetchStockData() {
        let url = URL(string: "https://app.finabl.org/api/stockData/detailedStockData/\(ticker)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                // Decode the data into an array of dictionaries
                if let stockArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let stock = stockArray.first,
                   let price = stock["price"] as? Double, let description = stock["description"] as? String {
                    print("Stock data decoded: \(stock)")
                    DispatchQueue.main.async {
                        self.stockPrice = String(format: "$%.2f", price)
                        self.stockDescription = description
                        print("Updated stock price: \(self.stockPrice)")
                    }
                } else {
                    print("Failed to extract stock data from JSON")
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    func fetchPriceChangeData() {
        let url = URL(string: "https://app.finabl.org/api/stockData/stockPriceChange/\(ticker)")!
        print("Requesting URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 404 {
                    print("Endpoint not found. Please verify the URL or API path.")
                }
                print("Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "Unknown")")
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Print raw response for debugging
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                // Decode the JSON response
                if let priceChangeArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let priceChangeInfo = priceChangeArray.first {
                    print("Price change data decoded: \(priceChangeInfo)")
                    DispatchQueue.main.async {
                        // Populate priceChangeData dictionary
                        self.priceChangeData = priceChangeInfo.reduce(into: [:]) { dict, item in
                            if let key = item.key as? String, let value = item.value as? Double {
                                dict[key] = value
                            }
                        }
                        updatePriceChange()
                    }
                } else {
                    print("Failed to extract price change data from JSON")
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }


    func updatePriceChange() {
        // Define suffixes for each time range
        let finablToFMP: [String: String] = [
            "1D": "1D",
            "5D": "5D",
            "1M": "1M",
            "3M": "3M",
            "6M": "6M",
            "YTD": "ytd",
            "1Y": "1Y",
            "3Y": "3Y",
            "5Y": "5Y",
            "10Y": "10Y",
            "Max": "max"
        ]
        
        let finablToChart: [String: String] = [
            "1D": "1day",
            "5D": "5day",
            "1M": "1M",
            "3M": "3M",
            "6M": "6M",
            "YTD": "ytd",
            "1Y": "1Y",
            "3Y": "3Y",
            "5Y": "5Y",
            "10Y": "10Y",
            "Max": "max"
        ]
        
        let timeSuffixes: [String: String] = [
            "1D": "today",
            "5D": "over the past week",
            "1M": "this month",
            "3M": "over the past 3 months",
            "6M": "over the past 6 months",
            "ytd": "year-to-date",
            "1Y": "this year",
            "3Y": "in 3 years",
            "5Y": "in 5 years",
            "10Y": "in 10 years",
            "max": "since inception"
        ]
        
        if let change = priceChangeData[selectedTimeRange], let suffix = timeSuffixes[finablToFMP[selectedTimeRange]!] {
            self.priceChange = "\(String(format: "%.02f", change)) \(suffix)"
            self.priceChangeColor = change >= 0 ? .green : .red
            
            fetchData(timeframe: "1day")
        } else {
            self.priceChange = "0.00%"
            self.priceChangeColor = .gray
        }
    }
    
}

struct ActionButton: View {
    let image: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: image)
                .font(.title3)
                .foregroundColor(.blue)
            Text(title)
                .font(Font.custom("Anuphan", size: 12))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}



#Preview {
    AlpacaStockView(ticker: "AAPL")
}
