//
//  CompetitionsView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/21/25.
//

import SwiftUI

struct Competition: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let participants: [String] // List of participant emails
    let joined: Bool
    let startDate: String
    let endDate: String
    let isPrivate: Bool
    let type: CompetitionType
    let shareLink: String
}

enum CompetitionType: String, CaseIterable {
    case highestYield = "Highest % yield over time"
    case highestYieldSector = "Highest % yield over time in X sector"
    case mostProfitableDiversified = "Most profitable Diversified Portfolio"
    case longestTradeStreak = "Longest Daily Trade Streak"
    case mostProfitableTechie = "Most profitable “Techie” Portfolio"
    case mostProfitableGreen = "Most profitable “Green” Portfolio"
    case highestProfitableSocialImpact = "Highest profitable “Social Impact” Portfolio"
}

struct CompetitionsView: View {
    @State private var competitions: [Competition] = [
        Competition(
            name: "Tech Portfolio Challenge",
            description: "Build the most profitable tech-focused portfolio.",
            participants: ["user1@example.com", "user2@example.com", "user3@example.com"],
            joined: true,
            startDate: "01/01/2025",
            endDate: "01/31/2025",
            isPrivate: false,
            type: .mostProfitableTechie,
            shareLink: "https://example.com/competition1"
        ),
        Competition(
            name: "Green Portfolio Challenge",
            description: "Create the most profitable eco-friendly portfolio.",
            participants: ["user4@example.com", "user5@example.com"],
            joined: false,
            startDate: "02/01/2025",
            endDate: "02/28/2025",
            isPrivate: true,
            type: .mostProfitableGreen,
            shareLink: "https://example.com/competition2"
        )
    ]

    @State private var selectedCompetition: Competition?
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Competitions")
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    // Settings or options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            VStack {
                HStack {
                    Text("Join competition")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .padding(.leading, 16)
                    Spacer()
                    Button(action: {
                        // Action to add a new competition
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.vertical, 10)

                List {
                    ForEach(competitions) { competition in
                        NavigationLink(destination: CompetitionsDetailedView(competition: competition)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(competition.name)
                                        .font(Font.custom("Anuphan-Medium", size: 18))
                                    Text(competition.description)
                                        .font(Font.custom("Anuphan-Regular", size: 16))
                                        .foregroundColor(.gray)
                                    Text("Start: \(competition.startDate) - End: \(competition.endDate)")
                                        .font(Font.custom("Anuphan-Regular", size: 16))
                                        .foregroundColor(.gray)
                                    Text("\(competition.participants.count) people joined")
                                        .font(Font.custom("Anuphan-Regular", size: 16))
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            selectedCompetition = competition
                                        }
                                }
                                Spacer()
                                VStack {
                                    if competition.joined {
                                        Text("Joined")
                                            .font(Font.custom("Anuphan-Medium", size: 14))
                                            .frame(width: 80, height: 30)
                                            .foregroundColor(.gray)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    } else {
                                        Button(action: {
                                            // Action to join the competition
                                        }) {
                                            Text("Join")
                                                .font(Font.custom("Anuphan-Medium", size: 14))
                                                .frame(width: 80, height: 30)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    Button(action: {
                                        // Share competition link
                                        print("Share link: \(competition.shareLink)")
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())
                .sheet(item: $selectedCompetition) { competition in
                    VStack {
                        Text("Participants")
                            .font(Font.custom("Anuphan-Bold", size: 18))
                            .padding()
                        List(competition.participants, id: \.self) { email in
                            Text(email)
                                .font(Font.custom("Anuphan-Medium", size: 16))
                        }
                    }
                }

            }
        }
    }
}

#Preview {
    CompetitionsView()
}
