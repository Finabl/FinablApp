//
//  StockCandleStickTestView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/16/25.
//

import SwiftUI
// Model for EOD API response
struct HistoricalPriceResponse: Decodable {
    let historical: [Candlestick]
}
// Updated Candlestick Model for EOD API
struct EODCandlestick: Decodable {
    let date: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    
    enum CodingKeys: String, CodingKey {
        case date, open, high, low, close
    }
}
// MARK: - Network Manager for FMP
class FMPAPI {
    private let apiKey = "b1ChpDMUHgCwvYTPsv7S1VGarBQ1oxEr" // Replace with your actual FMP API key
    private let baseUrl = "https://financialmodelingprep.com/api/v3"
    func fetchLineChartData(symbol: String, from: String, to: String, completion: @escaping (Result<[Candlestick], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let fromDate = dateFormatter.date(from: from),
              let toDate = dateFormatter.date(from: to) else {
            completion(.failure(NSError(domain: "Invalid Date Format", code: 0, userInfo: nil)))
            return
        }
        
        let daysDifference = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
        
        var endpoint: String
        
        if daysDifference <= 30 {
            // Use Intraday Chart API for ≤ 1 month
            endpoint = "\(baseUrl)/historical-chart/5min/\(symbol)?from=\(from)&to=\(to)&apikey=\(apiKey)"
        } else {
            // Use Daily EOD API for > 1 month
            endpoint = "\(baseUrl)/historical-price-full/\(symbol)?from=\(from)&to=\(to)&serietype=line&apikey=\(apiKey)"
        }
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                if daysDifference <= 30 {
                    // Decode Intraday Chart Data (direct array)
                    let candlesticks = try JSONDecoder().decode([Candlestick].self, from: data)
                    completion(.success(candlesticks))
                } else {
                    // Decode Daily EOD Data (wrapped in "historical" key)
                    let decodedResponse = try JSONDecoder().decode(HistoricalPriceResponse.self, from: data)
                    completion(.success(decodedResponse.historical))
                }
            } catch {
                print("JSON Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchCandlestickData(symbol: String, timeframe: String = "1hour", completion: @escaping (Result<[Candlestick], Error>) -> Void) {
        let endpoint = "\(baseUrl)/historical-chart-full/\(timeframe)/\(symbol)?apikey=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let candlesticks = try JSONDecoder().decode([Candlestick].self, from: data)
                completion(.success(candlesticks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - SwiftUI View for Candlestick Chart
struct StockCandlestickView: View {
    @State private var candlestickData: [Candlestick] = []
    @State private var isLoading = true
    @State private var selectedCandlestick: Candlestick? = nil
    private let fmpAPI = FMPAPI()

    var body: some View {
        VStack {
            if isLoading {
                Text("Loading data...")
                    .onAppear {
                        fetchData()
                    }
            } else if candlestickData.isEmpty {
                Text("No data available")
            } else {
                ZStack {
                    CandlestickChart(data: candlestickData, selectedCandlestick: $selectedCandlestick)
                        .frame(height: 300)
                        .padding()

                    // Display details of the selected candlestick
                    if let selected = selectedCandlestick {
                        VStack {
                            Text("Date: \(selected.date)")
                            Text("Open: \(selected.open)")
                            Text("High: \(selected.high)")
                            Text("Low: \(selected.low)")
                            Text("Close: \(selected.close)")
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .position(x: 150, y: 50) // Adjust position for better placement
                    }
                }
            }
        }
    }

    private func fetchData() {
        fmpAPI.fetchCandlestickData(symbol: "AAPL", timeframe: "1hour") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.candlestickData = data
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}

// MARK: - SwiftUI Candlestick Chart with Zoom and Pan
struct CandlestickChart: View {
    let data: [Candlestick]
    @Binding var selectedCandlestick: Candlestick?

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            let width = (geometry.size.width / CGFloat(data.count)) * scale
            let maxPrice = data.map { $0.high }.max() ?? 1
            let minPrice = data.map { $0.low }.min() ?? 0

            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let candlestick = data[index]
                    let xPosition = CGFloat(index) * width + offset
                    let openY = CGFloat((candlestick.open - minPrice) / (maxPrice - minPrice)) * geometry.size.height
                    let closeY = CGFloat((candlestick.close - minPrice) / (maxPrice - minPrice)) * geometry.size.height
                    let highY = CGFloat((candlestick.high - minPrice) / (maxPrice - minPrice)) * geometry.size.height
                    let lowY = CGFloat((candlestick.low - minPrice) / (maxPrice - minPrice)) * geometry.size.height

                    // Draw candlestick only if it's within the visible bounds
                    if xPosition >= 0 && xPosition <= geometry.size.width {
                        // Candlestick Body
                        Rectangle()
                            .fill(candlestick.open > candlestick.close ? Color.red : Color.green)
                            .frame(width: width * 0.8, height: abs(openY - closeY))
                            .position(x: xPosition + width / 2, y: (openY + closeY) / 2)

                        // High-Low Line
                        Path { path in
                            path.move(to: CGPoint(x: xPosition + width / 2, y: highY))
                            path.addLine(to: CGPoint(x: xPosition + width / 2, y: lowY))
                        }
                        .stroke(candlestick.open > candlestick.close ? Color.red : Color.green, lineWidth: 1)
                    }
                }

                // Add interactivity for selecting a candlestick
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let index = Int((value.location.x - offset) / width)
                                if index >= 0 && index < data.count {
                                    selectedCandlestick = data[index]
                                }
                            }
                    )
            }
            .gesture(
                // Magnification gesture for zooming
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(0.5, min(value, 5.0)) // Limit zoom scale between 0.5x and 5x
                    }
            )
            .gesture(
                // Drag gesture for panning
                DragGesture()
                    .onChanged { value in
                        offset += value.translation.width
                    }
                    .onEnded { _ in
                        // Ensure offset stays within bounds
                        offset = max(offset, -geometry.size.width)
                        offset = min(offset, geometry.size.width)
                    }
            )
        }
    }
}



#Preview {
    StockCandlestickView()
}


