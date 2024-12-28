//
//  LoginView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        NavigationStack {
            VStack {
                Image("fin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                //Text("Finabl")
                
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocorrectionDisabled()
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    print("Long user in...")
                }
                label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }.foregroundStyle(Color(.white))
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
            .background(Color(.blue))
                .cornerRadius(10)
                .padding(.top, 24)
            Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing: 2) {
                        Text("Don't have an account?")
                            Text("Sign Up")
                                .fontWeight(.bold)
                            
                    }
                        .font(.system(size: 14))
                    }
                
        }
        }
    }
}

#Preview {
    LoginView()
}
