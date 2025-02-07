//
//  ContentView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/21/24.
//

import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @State private var userEmail: String? = nil
    @State private var isProfileViewActive: Bool = false
    @State private var hasFinancialGoals: Bool = false
    @State private var hasLearningGoals: Bool = false

    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                HomeView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Search Tab
            NavigationStack {
                TradingSimulatorView()
                //RealTimeLineChartView()
                //StockCandlestickView()
                /*VStack {
                    Text("Search")
                        .font(Font.custom("Anuphan-Light", size: 24))
                        .padding()
                }*/
            }
            .tabItem {
                VStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Learn Tab
            NavigationStack {
                LearnHubView().toolbar(.hidden)
            }
            .tabItem {
                VStack {
                    Image(systemName: "book.fill")
                    Text("Learn")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Social Tab
            NavigationStack {
                SocialHubView().toolbar(.hidden)
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.3.fill")
                    Text("Social")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }
        }
    }
}

#Preview {
    TabBarView()
}
