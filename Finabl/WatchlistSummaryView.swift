//
//  WatchlistSummaryView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 2/8/25.
//

import SwiftUI

struct WatchlistSummaryView: View {
    @State var watchlist: Watchlist
    @State private var newTicker: String = ""
    var userEmail: String
    
    var body: some View {
        VStack {
            Text("Watchlist: \(watchlist.name)")
                .font(Font.custom("Anuphan-Bold", size: 20))
                .padding(.top)
            
            List {
                ForEach(watchlist.tickers, id: \.self) { ticker in
                    NavigationLink(destination: AlpacaStockView(ticker: ticker)) {
                        HStack {
                            Text(ticker)
                                .font(Font.custom("Anuphan-Regular", size: 16))
                            Spacer()
                            Button(action: { removeTicker(ticker) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }.navigationBarBackButtonHidden(true)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        removeTicker(watchlist.tickers[index])
                    }
                }
            }
            
            HStack {
                TextField("Add Ticker", text: $newTicker)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addTicker) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
        .navigationTitle(watchlist.name)
    }
    
    /// Add Ticker to Watchlist
    func addTicker() {
        guard !newTicker.isEmpty else { return }
        
        let url = URL(string: "https://app.finabl.org/api/users/user/\(userEmail)/watchlist/\(watchlist.id)/ticker")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["ticker": newTicker.uppercased()])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    watchlist.tickers.append(newTicker.uppercased())
                    newTicker = ""
                }
            }
        }.resume()
    }
    
    /// Remove Ticker from Watchlist
    func removeTicker(_ ticker: String) {
        let url = URL(string: "https://app.finabl.org/api/users/user/\(userEmail)/watchlist/\(watchlist.id)/ticker/\(ticker)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    watchlist.tickers.removeAll { $0 == ticker }
                }
            }
        }.resume()
    }
}


/*#Preview {
    WatchlistSummaryView()
}*/
