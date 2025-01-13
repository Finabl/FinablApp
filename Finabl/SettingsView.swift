import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isSignedIn: Bool
    @State private var isSigningOut: Bool = false 

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account").font(Font.custom("Anuphan-Medium", size: 16))) {
                    NavigationLink("Account Information", destination: Text("Account Information Details"))
                    NavigationLink("Privacy", destination: Text("Privacy Settings"))
                    NavigationLink("Subscription", destination: Text("Subscription Details"))
                    NavigationLink("Tax Center", destination: Text("Tax Center Details"))
                }

                Section(header: Text("App Preferences").font(Font.custom("Anuphan-Medium", size: 16))) {
                    NavigationLink("Documentation", destination: Text("Documentation Details"))
                    NavigationLink("Support", destination: Text("Support Details"))
                    NavigationLink("Notifications", destination: NotificationSettingsView())
                    NavigationLink("Learning Preferences", destination: Text("Learning Preferences Details"))
                }

                Section(header: Text("Rewards").font(Font.custom("Anuphan-Medium", size: 16))) {
                    NavigationLink("Tuition Rewards Program*", destination: Text("Tuition Rewards Details"))
                    NavigationLink("Feedback Form", destination: FeedbackFormView())
                }

                Section(header: Text("Account Actions").font(Font.custom("Anuphan-Medium", size: 16))) {
                    if isSigningOut {
                        ProgressView("Signing out...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button(action: signOut) {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func signOut() {
        isSigningOut = true
        do {
            try Auth.auth().signOut()
            isSigningOut = false
            isSignedIn = false // Update the binding to reflect sign-out in SocialHubView
            presentationMode.wrappedValue.dismiss() // Dismiss SettingsView
        } catch let error as NSError {
            isSigningOut = false
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct NotificationSettingsView: View {
    @State private var priceAlerts: Bool = true
    @State private var personalizedNotifications: Bool = true

    var body: some View {
        Form {
            Toggle("Price Alerts", isOn: $priceAlerts)
            Toggle("Personalized Notifications", isOn: $personalizedNotifications)
        }
        .navigationTitle("Notifications")
    }
}

struct FeedbackFormView: View {
    @State private var feedback: String = ""
    @State private var submitDisabled: Bool = false

    var body: some View {
        VStack {
            Text("Your Feedback is Important")
                .font(Font.custom("Anuphan-Medium", size: 18))
                .padding(.bottom, 16)

            TextEditor(text: $feedback)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding(.horizontal)

            Button(action: {
                // Simulate submission logic
                submitDisabled = true
                // Add your submission logic here
            }) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(submitDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(submitDisabled)
            .padding()
        }
        .padding()
        .navigationTitle("Feedback Form")
    }
}

#Preview {
    SettingsView(isSignedIn: .constant(true))
}
