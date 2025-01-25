//
//  NotifView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/20/25.
//

import SwiftUI

struct NotifView: View {
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
                Text("Notifications")
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
            
            ScrollView {
                ForEach(1...10, id: \.self) { notif in
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Notification!")
                                .font(.custom("Anuphan-Bold", size: 16))
                            Spacer()
                        }
                        Text("You haven't created your portfolios yet...")
                            .font(.custom("Anuphan-Regular", size: 14))
                    Button(action: {
                        //presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create one now!")
                    }
                        
                    }.padding()
                        .background(.secondary)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    
                }.padding()
                
            }
            
        }
    }
}

#Preview {
    NotifView()
}
