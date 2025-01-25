//
//  NewsViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/17/25.
//

import Foundation
import Combine

struct NewsArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let summary: String
    let image: String
    let publishedDate: String
    
    var timeAgo: String {
        // Calculate time difference between publishedDate and now
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: publishedDate) else { return "N/A" }
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
        }
    }
}


class NewsViewModel: ObservableObject {
    @Published var newsArticles: [NewsArticle] = []
    private let baseUrl = "https://app.finabl.org/api/stockData/detailedStockNews/"
    
    func fetchNews(tickers: String) {
        // Get yesterday's and today's dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let yesterday = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        // Build the API URL
        let urlString = "\(baseUrl)/\(tickers)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                print("data \(data)")
                do {
                    let articles = try JSONDecoder().decode([NewsArticle].self, from: data)
                    DispatchQueue.main.async {
                        self.newsArticles = articles
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }.resume()
    }
}

