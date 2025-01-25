//
//  MessagesView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/2/25.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct MessagesView: View {
    @Environment(\.presentationMode) var presentationMode // For back button functionality
    @StateObject private var viewModel: ChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    
    public init(
        channelListController: ChatChannelListController? = nil
    ) {
        let channelListVM = ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Messages")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        //ajdsfkasj
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ChannelList(
                    factory: DefaultViewFactory.shared,
                    channels: viewModel.channels,
                    selectedChannel: $viewModel.selectedChannel,
                    swipedChannelId: $viewModel.swipedChannelId,
                    onItemTap: { channel in
                        viewModel.selectedChannel = channel.channelSelectionInfo
                    },
                    onItemAppear: { index in
                        viewModel.checkForChannels(index: index)
                    },
                    channelDestination: DefaultViewFactory.shared.makeChannelDestination()
                )

                }.toolbar(.hidden, for: .tabBar)
            }
        }
    }

    





#Preview {
    MessagesView()
}
