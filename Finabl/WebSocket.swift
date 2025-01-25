//
//  WebSocket.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/20/25.
//

/*
 
 import SwiftUI

 // MARK: - Model for Real-Time Data
 struct RealTimeStockData: Decodable {
     let s: String // Ticker symbol
     let t: Int // Timestamp
     let type: String // Type of message ('T', 'Q', 'B')
     let ap: Double? // Ask price
     let `as`: Int? // Ask size
     let bp: Double? // Bid price
     let bs: Int? // Bid size
     let lp: Double? // Last price
     let ls: Int? // Last size
 }

 // MARK: - WebSocket Manager
 class WebSocketManager: ObservableObject {
     @Published var realTimeData: [RealTimeStockData] = []
     private var webSocketTask: URLSessionWebSocketTask?

     func connect() {
         guard let url = URL(string: "wss://websockets.financialmodelingprep.com") else { return }
         webSocketTask = URLSession.shared.webSocketTask(with: url)
         webSocketTask?.resume()

         // Send login message
         let loginMessage = """
         {"event":"login","data":{"apiKey":"b1ChpDMUHgCwvYTPsv7S1VGarBQ1oxEr"}}
         """
         send(message: loginMessage)

         // Subscribe to stock updates
         let subscribeMessage = """
         {"event":"subscribe","data":{"ticker":["AAPL"]}}
         """
         send(message: subscribeMessage)

         receive()
     }

     func disconnect() {
         guard webSocketTask != nil else { return }
         let unsubscribeMessage = """
         {"event":"unsubscribe","data":{"ticker":["AAPL"]}}
         """
         send(message: unsubscribeMessage)
         webSocketTask?.cancel(with: .normalClosure, reason: nil)
         webSocketTask = nil
     }

     private func send(message: String) {
         let message = URLSessionWebSocketTask.Message.string(message)
         webSocketTask?.send(message) { error in
             if let error = error {
                 print("WebSocket send error: \(error)")
             }
         }
     }

     private func receive() {
         webSocketTask?.receive { [weak self] result in
             switch result {
             case .success(let message):
                 switch message {
                 case .string(let text):
                     print("Received WebSocket message: \(text)")
                     if let data = text.data(using: .utf8) {
                         do {
                             let decodedData = try JSONDecoder().decode(RealTimeStockData.self, from: data)
                             DispatchQueue.main.async {
                                 self?.realTimeData.append(decodedData)
                             }
                         } catch {
                             print("Decoding error: \(error.localizedDescription)")
                         }
                     }
                 default:
                     break
                 }
             case .failure(let error):
                 print("WebSocket receive error: \(error.localizedDescription)")
             }
             self?.receive() // Continue listening
         }
     }
 }

 // MARK: - SwiftUI Real-Time Line Chart View
 struct RealTimeLineChartView: View {
     @StateObject private var webSocketManager = WebSocketManager()
     @State private var isLoading = true

     var body: some View {
         VStack {
             if isLoading {
                 Text("Loading real-time data...")
                     .onAppear {
                         webSocketManager.connect()
                         DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                             if webSocketManager.realTimeData.isEmpty {
                                 isLoading = false
                             }
                         }
                     }
                     .onDisappear {
                         webSocketManager.disconnect()
                     }
             } else if webSocketManager.realTimeData.isEmpty {
                 Text("No data available")
             } else {
                 LineChartWithTouch(data: webSocketManager.realTimeData)
                     .frame(height: 300)
                     .padding()
                     .onAppear {
                         isLoading = false
                     }
             }
         }
     }
 }

 // MARK: - SwiftUI Line Chart with Touch Interaction
 struct LineChartWithTouch: View {
     let data: [RealTimeStockData]
     @State private var selectedPoint: CGPoint? = nil

     var body: some View {
         if data.isEmpty {
             Text("No data to display") // Handle empty data gracefully
         } else {
             GeometryReader { geometry in
                 let width = geometry.size.width / CGFloat(data.count)
                 let maxValue = data.compactMap { $0.lp }.max() ?? 1
                 let minValue = data.compactMap { $0.lp }.min() ?? 0

                 ZStack {
                     Path { path in
                         for (index, point) in data.enumerated() {
                             guard let lastPrice = point.lp else { continue }
                             let xPosition = CGFloat(index) * width
                             let yPosition = geometry.size.height - (CGFloat(lastPrice - minValue) /
                                                                     CGFloat(maxValue - minValue) * geometry.size.height)

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

                     // Vertical line for touch interaction
                     if let selected = selectedPoint {
                         Path { path in
                             path.move(to: CGPoint(x: selected.x, y: 0))
                             path.addLine(to: CGPoint(x: selected.x, y: geometry.size.height))
                         }
                         .stroke(Color.red, lineWidth: 1)

                         // Safely access data by clamping index within bounds
                         let index = min(max(Int(selected.x / width), 0), data.count - 1)
                         let closestData = data[index]

                         VStack {
                             Text("Last Price: \(closestData.lp ?? 0)")
                             Text("Volume: \(closestData.ls ?? 0)")
                         }
                         .padding()
                         .background(Color.black.opacity(0.8))
                         .foregroundColor(.white)
                         .cornerRadius(10)
                         .shadow(radius: 5)
                         .position(x: selected.x, y: 50)
                     }
                 }
                 .gesture(
                     DragGesture()
                         .onChanged { value in
                             selectedPoint = value.location
                         }
                         .onEnded { _ in
                             selectedPoint = nil
                         }
                 )
             }
         }
     }
 }


 // MARK: - Preview
 #Preview {
     RealTimeLineChartView()
 }

 */
