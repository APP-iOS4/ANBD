//
//  ChatView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    @State private var isShowingConfirmSheet: Bool = false
    @State private var isShowingCustomAlertView: Bool = false
    var body: some View {
        VStack {
            if chatViewModel.chatRooms.isEmpty {
                Text("진행 중인 채팅방이 없습니다.")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.body1)
            } else {
                ZStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(chatViewModel.chatRooms) { channel in
                                Button(action: {
                                    coordinator.channel = channel
                                    coordinator.chatPath.append(Page.chatDetailView)
                                }, label: {
                                    ChatListCell(channel: channel)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 3)
                                })
                            }
                        }
                    }
                    
                    if isShowingCustomAlertView {
                        CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertView, viewType: .leaveChatRoom) {
                            print("채팅방 삭제 고고 ~~")
                        }
                    }
                }
                .confirmationDialog("", isPresented: $isShowingConfirmSheet) {
                    Button("채팅방 나가기", role: .destructive) {
                        isShowingCustomAlertView.toggle()
                    }
                } message: {
                    Text("해당 채팅방을 나가시겠습니까?")
                }
            }
        }
        .navigationTitle("채팅")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatViewModel.loadUserInfo()
            chatViewModel.fetchChatRooms()
        }
        .onDisappear {
            chatViewModel.resetChannelListener()
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ChatViewModel())
    }
}
