//
//  WalletView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/20/25.
//

import SwiftUI

import SwiftUI

struct WalletView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Wallet")
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
                Text("$0.00")
                    .font(Font.custom("Anuphan-Bold", size: 48))
                    .padding(.top, 20)
                Text("Total Buying Power")
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.gray)
                Button(action: {
                    // Add action to navigate to AddMoneyView
                }) {
                    Text("+ Add money")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Banks and Cards")
                        .font(Font.custom("Anuphan-Bold", size: 20))
                        .padding(.leading, 16)

                    List {
                        ForEach(0..<3) { index in
                            HStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray.opacity(0.5))
                                VStack(alignment: .leading) {
                                    Text("Bank acc name")
                                        .font(Font.custom("Anuphan-Medium", size: 16))
                                    Text("•••• 285\(index + 1)")
                                        .font(Font.custom("Anuphan-Regular", size: 14))

                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .padding(.top, 10)
                Spacer()

        }
    }
}


#Preview {
    WalletView()
}
