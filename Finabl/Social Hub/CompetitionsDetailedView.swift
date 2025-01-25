//
//  CompetitionsDetailedView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/21/25.
//

import SwiftUI

struct CompetitionsDetailedView: View {
    let competition: Competition

    @State private var selectedTab: String = "Overview"

    var body: some View {
        VStack {
            // Tab Selector
            HStack {
                Button(action: {
                    selectedTab = "Overview"
                }) {
                    VStack {
                        Text("Overview")
                            .font(.headline)
                            .foregroundColor(selectedTab == "Overview" ? .black : .gray)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == "Overview" ? .blue : .clear)
                    }
                }
                Spacer()
                Button(action: {
                    selectedTab = "Leaderboard"
                }) {
                    VStack {
                        Text("Leaderboard")
                            .font(.headline)
                            .foregroundColor(selectedTab == "Leaderboard" ? .black : .gray)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == "Leaderboard" ? .blue : .clear)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()

            // Tab Content
            if selectedTab == "Overview" {
                overviewTab
            } else {
                leaderboardTab
            }

            Spacer()
        }
        .navigationBarTitle(competition.name, displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // Action for more options
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.black)
        })
    }

    // Overview Tab Content
    var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(competition.startDate) - \(competition.endDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(competition.participants.count) competitors")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Graph Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 150)
                .overlay(
                    VStack {
                        Text("Your entry")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("$0.00")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("+5 rank today")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Text("$0.00 (0.00%) today")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                )

            // Competition Description
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding()
    }

    // Leaderboard Tab Content
    var leaderboardTab: some View {
        List {
            ForEach(competition.participants.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading) {
                        Text("Person")
                            .font(.headline)
                        Text("$0.00")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("#\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(PlainListStyle())
    }
}



#Preview {
    CompetitionsDetailedView(
        competition: Competition(
            name: "Tech Portfolio Challenge",
            description: "Build the most profitable tech-focused portfolio.",
            participants: ["user1@example.com", "user2@example.com", "user3@example.com"],
            joined: true,
            startDate: "01/01/2025",
            endDate: "01/31/2025",
            isPrivate: false,
            type: .mostProfitableTechie,
            shareLink: "https://example.com/competition1"
        )
    )
}
