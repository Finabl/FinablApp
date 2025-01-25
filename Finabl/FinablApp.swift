//
//  FinablApp.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/21/24.
//

import SwiftUI
import Firebase
import StreamChat
import StreamChatSwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FinablApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    var chatClient: ChatClient = {
        //For the tutorial we use a hard coded api key and application group identifier
        var config = ChatClientConfig(apiKey: .init("8br4watad788"))
        config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"

        // The resulting config is passed into a new `ChatClient` instance.
        let client = ChatClient(config: config)
        return client
    }()
    
    @State var streamChat: StreamChat?
    
    init() {
        
        //var colors = ColorPalette()
        //let streamBlue = UIColor(red: 0, green: 108.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        //colors.messageCurrentUserBackground = [streamBlue]
        //colors.messageCurrentUserTextColor = .white
        
        var fonts = Fonts()
        fonts.footnoteBold = Font.custom("Anuphan-Bold", size: 14)
        fonts.footnote = Font.custom("Anuphan-Regular", size: 14)
        fonts.body = Font.custom("Anuphan-Medium", size: 16)
        fonts.title = Font.custom("Anuphan-Bold", size: 20)
        fonts.bodyBold = Font.custom("Anuphan-Bold", size: 16)
        fonts.headline = Font.custom("Anuphan-Medium", size: 18)
        fonts.headlineBold = Font.custom("Anuphan-Bold", size: 18)
        
        let appearance = Appearance(fonts: fonts)

        let streamChat = StreamChat(chatClient: chatClient, appearance: appearance)
        connectUser()
    }
    
    var body: some Scene {
        
        WindowGroup {
            TabBarView() 
        }
    }
    
    private func connectUser() {
        // This is a hardcoded token valid on Stream's tutorial environment.
        let token = try! Token(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.kFSLHRB5X62t0Zlc7nwczWUfsQMwfkpylC6jCUZ6Mc0")
        
        // Call `connectUser` on our SDK to get started.
        chatClient.connectUser(
            userInfo: .init(
                id: "luke_skywalker",
                name: "Luke Skywalker",
                imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!
            ),
            token: token
        ) { error in
            if let error = error {
                // Some very basic error handling only logging the error.
                log.error("connecting the user failed \(error)")
                return
            }
        }
    }
}



//Allows for Custom colors plz don't delete
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
