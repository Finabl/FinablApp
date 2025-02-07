//
//  SimpleLineChartView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/16/25.
//

import SwiftUI

// MARK: - Model for Line Chart Data
struct Candlestick: Decodable {
    let date: String // Date (e.g., "2023-01-16 15:00:00")
    let open: Double // Open price
    let high: Double // High price
    let low: Double  // Low price
    let close: Double // Close price
    let volume: Int // Volume
}


// MARK: - SwiftUI Line Chart View
struct StockLineChartView: View {
    @State private var lineChartData: [Candlestick] = []
    @State private var isLoading = true
    private let fmpAPI = FMPAPI()

    var body: some View {
        VStack {
            if isLoading {
                Text("Loading data...")
                    .onAppear {
                        fetchData()
                    }
            } else if lineChartData.isEmpty {
                Text("No data available")
            } else {
                LineChart(data: lineChartData)
                    .frame(height: 290)
                    .padding()
            }
        }
    }

    private func fetchData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let today = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: today)! // Example: 5-day history

        let fromDate = dateFormatter.string(from: pastDate)
        let toDate = dateFormatter.string(from: today)

        fmpAPI.fetchLineChartData(symbol: "AAPL", from: fromDate, to: toDate) { result in
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

}

// MARK: - SwiftUI Line Chart
struct LineChart: View {
    let data: [Candlestick]

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGFloat = 0.0
    @State private var selectedPoint: Candlestick? = nil

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width / CGFloat(data.count) * scale
            let maxValue = data.map { $0.close }.max() ?? 1
            let minValue = data.map { $0.close }.min() ?? 0

            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.2))
                    .shadow(radius: 5)

                // Line chart path
                Path { path in
                    for (index, point) in data.enumerated() {
                        let xPosition = CGFloat(index) * width + offset
                        let yPosition = geometry.size.height - (CGFloat(point.close - minValue) / CGFloat(maxValue - minValue) * geometry.size.height)

                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )

                // Gradient fill under the line
                Path { path in
                    for (index, point) in data.enumerated() {
                        let xPosition = CGFloat(index) * width + offset
                        let yPosition = geometry.size.height - (CGFloat(point.close - minValue) / CGFloat(maxValue - minValue) * geometry.size.height)

                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Interactive overlay
                if let selected = selectedPoint {
                    VStack {
                        Text("Date: \(selected.date)")
                        Text("Close: \(selected.close)")
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .position(x: 150, y: 50)
                }
            }
            .gesture(
                // Drag gesture for interactivity
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let index = Int((value.location.x - offset) / width)
                        if index >= 0 && index < data.count {
                            selectedPoint = data[index]
                        }
                    }
            )
            .gesture(
                // Pinch-to-zoom gesture
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(1.0, min(value, 5.0)) // Limit zoom between 1x and 5x
                    }
            )
            .gesture(
                // Drag gesture for panning
                DragGesture()
                    .onChanged { value in
                        offset += value.translation.width
                    }
                    .onEnded { _ in
                        // Keep offset within bounds
                        offset = max(offset, -geometry.size.width)
                        offset = min(offset, geometry.size.width)
                    }
            )
        }
    }
}




#Preview {
    StockLineChartView()
}

