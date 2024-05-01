//
//  ChatDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import PhotosUI
import ANBDModel

struct ChatDetailView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @StateObject private var coordinator = Coordinator.shared
    @Environment(\.colorScheme) var colorScheme
    
    /// 보낼 메시지 관련 변수
    @State private var message: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedPhoto: Data?
    
    /// Sheet 관련 변수
    @State private var isShowingCustomAlertView: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var imageData: [Data] = []
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @State private var isWithdrawlUser: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ChatHeaderView(trade: chatViewModel.selectedTrade, isShowingStateChangeCustomAlert: $isShowingStateChangeCustomAlert)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .onAppear {
                        Task {
                            if let trade = chatViewModel.selectedTrade {
                                await chatViewModel.loadTrade(tradeID: trade.id)
                            }
                        }
                    }
                
                Divider()
                
                /// message 내역
                ScrollView {
                    if let channel = chatViewModel.selectedChannel {
                        LazyVStack {
                            ForEach(chatViewModel.groupedMessages, id: \.day) { day, messages in
                                ForEach(messages) { message in
                                    MessageCell(message: message, isLast: message == chatViewModel.messages.last, channel: channel, isShowingImageDetailView: $isShowingImageDetailView, imageData: $imageData)
                                        .padding(.vertical, 1)
                                        .padding(.horizontal, 20)
                                }
                                if let last = chatViewModel.groupedMessages.last , last.day == day{
                                    MessageDateDividerView(dateString: day)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 20)
                                } else {
                                    MessageDateDividerView(dateString: day)
                                        .padding(20)
                                }
                            }
                            .rotationEffect(Angle(degrees: 180))
                            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                            
                            Color.clear
                                .onAppear {
                                    Task {
                                        try await chatViewModel.addListener(channelID: channel.id)
                                    }
                                }
                        }
                        .onChange(of: chatViewModel.messages) { message in
                            Task {
                                try await chatViewModel.resetUnreadCount(channelID: channel.id)
                            }
                        }
                    }
                }
                .rotationEffect(Angle(degrees: 180))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                
                if #available(iOS 17.0, *) {
                    messageSendView
                        .padding()
                        .onChange(of: selectedImage) {
                            if let image = selectedImage {
                                sendImageMessage(image: image)
                            }
                        }
                } else {
                    messageSendView
                        .padding()
                        .onChange(of: selectedImage) { image in
                            if let image = image {
                                sendImageMessage(image: image)
                            }
                        }
                }
            }
            
            if isShowingStateChangeCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingStateChangeCustomAlert, viewType: .changeState) {
                    Task {
                        guard chatViewModel.selectedTrade != nil else { return }
                        guard let trade = chatViewModel.selectedTrade else { return}
                        await chatViewModel.updateTradeState(tradeID: trade.id, tradeState: trade.tradeState == .trading ? .finish : .trading)
                    }
                }
            }
            
            if isShowingCustomAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertView, viewType: .leaveChatRoom) {
                    Task {
                        if let channel = chatViewModel.selectedChannel, let lastMessage = chatViewModel.messages.last {
                            try await chatViewModel.leaveChatRoom(channelID: channel.id, lastMessageID: lastMessage.id)
                        }
                        coordinator.pop()
                    }
                }
            }
            
            if coordinator.isShowingToastView {
                VStack {
                    CustomToastView()
                    
                    Spacer()
                }
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .navigationTitle(chatViewModel.selectedUser.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .toolbar {
            if !chatViewModel.messages.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            coordinator.reportType = .chatRoom
                            if let channel = chatViewModel.selectedChannel {
                                coordinator.reportedObjectID = channel.id
                            }
                            coordinator.appendPath(.reportView)
                        } label: {
                            Label("채팅방 신고하기", systemImage: "exclamationmark.bubble")
                        }
                        
                        Button(role: .destructive) {
                            isShowingCustomAlertView.toggle()
                        } label: {
                            Label("채팅방 나가기", systemImage: "rectangle.portrait.and.arrow.forward")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray900)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(isShowingImageDetailView: $isShowingImageDetailView, images: $imageData, idx: .constant(0))
        }
        .onAppear {
            Task {
                ///탈퇴한 회원일 경우
                if chatViewModel.selectedUser.id == "" {
                    isWithdrawlUser = true
                }
                
                if let channel = chatViewModel.selectedChannel {
                    /// 안읽음 메시지 개수 갱신
                    try await chatViewModel.resetUnreadCount(channelID: channel.id)
                }
            }
        }
        .onDisappear {
            chatViewModel.resetMessageData()
        }
    }
    
    private func MessageDateDividerView(dateString: String) -> some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                Text(dateString)
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption1)
                
                Spacer()
            }
        }
    }
    
    
    // MARK: - 메시지 전송 뷰
    private var messageSendView: some View {
        HStack {
            /// 사진 전송
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundStyle(.gray400)
                    .padding(.horizontal, 5)
            }
            .disabled(isWithdrawlUser)
            
            TextField(isWithdrawlUser ? "탈퇴한 회원이므로 메시지를 보낼 수 없습니다" : "메시지 보내기", text: $message, axis: .vertical)
                .lineLimit(3, reservesSpace: false)
                .foregroundStyle(.gray900)
                .font(ANBDFont.Caption3)
                .padding(13)
                .disabled(isWithdrawlUser)
                .background {
                    Rectangle()
                        .fill(colorScheme == .light ? .gray50 : .gray700)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            
            /// 메시지 전송
            Button(action: {
                if !message.isEmpty && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    sendMessage()
                    message = ""
                }
            }, label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .foregroundStyle((message.isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? .gray400 : .accentColor)
                    .rotationEffect(.degrees(43))
            })
            .disabled(message.isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}


// MARK: - 필요 함수 · 변수 모아두기
extension ChatDetailView {
    
    /// 메시지 전송 함수
    private func sendMessage() {
        let newMessage = Message(userID: chatViewModel.user.id, userNickname: chatViewModel.user.nickname, content: message)
        
        Task {
            /// 채널이 없을 때
            if chatViewModel.selectedChannel == nil, let trade = chatViewModel.selectedTrade {
                let newChannel = Channel(participants: [trade.writerID, chatViewModel.user.id],
                                         participantNicknames: [trade.writerNickname, chatViewModel.user.nickname],
                                         lastMessage: "",
                                         lastSendDate: .now,
                                         lastSendId: chatViewModel.user.id,
                                         unreadCount: 0,
                                         tradeId: trade.id)
                
                try await chatViewModel.makeChannel(channel: newChannel)
                
                if let channel = chatViewModel.selectedChannel {
                    try await chatViewModel.addListener(channelID: channel.id)
                }
            }
            
            /// 채널 생성 후
            if let channel = chatViewModel.selectedChannel {
                try await chatViewModel.sendMessage(message: newMessage, channelID: channel.id)
            }
        }
    }
    
    /// 사진 메시지 전송 함수
    private func sendImageMessage(image: PhotosPickerItem) {
        Task {
            if let data = try? await image.loadTransferable(type: Data.self) {
                selectedPhoto = data
            }
            
            let newMessage = Message(userID: chatViewModel.user.id, userNickname: chatViewModel.user.nickname)
            
            if let imageData = selectedPhoto {
                /// 채널이 없을 때
                if chatViewModel.selectedChannel == nil, let trade = chatViewModel.selectedTrade {
                    let newChannel = Channel(participants: [trade.writerID, chatViewModel.user.id],
                                             participantNicknames: [trade.writerNickname, chatViewModel.user.nickname],
                                             lastMessage: "",
                                             lastSendDate: .now,
                                             lastSendId: chatViewModel.user.id,
                                             unreadCount: 0,
                                             tradeId: trade.id)
                    
                    try await chatViewModel.makeChannel(channel: newChannel)
                    
                    if let channel = chatViewModel.selectedChannel {
                        try await chatViewModel.addListener(channelID: channel.id)
                    }
                }
                
                /// 채널 있
                if let channel = chatViewModel.selectedChannel {
                    try await chatViewModel.sendImageMessage(message: newMessage, imageData: imageData, channelID: channel.id)
                }
            }
            
            selectedImage = nil
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailView()
            .environmentObject(ChatViewModel())
    }
}
