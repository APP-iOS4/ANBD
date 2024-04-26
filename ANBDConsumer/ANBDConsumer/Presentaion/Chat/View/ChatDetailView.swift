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
    @EnvironmentObject private var coordinator: Coordinator
    
    /// 채팅방 구분 변수
    @State var channel: Channel? = nil
    @State var trade: Trade? = nil
    @State private var imageData: Data?
    @State private var tradeState: TradeState = .trading
    
    /// 보낼 메시지 관련 변수
    @State private var message: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedPhoto: Data?
    
    /// Sheet 관련 변수
    @State private var isShowingCustomAlertView: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var detailImage: Image = Image("DummyPuppy3")
    @State private var isShowingStateChangeCustomAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ChatHeaderView(trade: trade, imageData: imageData, tradeState: $tradeState, isShowingStateChangeCustomAlert: $isShowingStateChangeCustomAlert)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                
                Divider()
                
                /// message 내역
                ScrollView {
                    LazyVStack {
                        ForEach(chatViewModel.groupedMessages, id: \.day) { day, messages in
                            
                            if let channel = channel {
                                ForEach(messages) { message in
                                    MessageCell(message: message, isLast: message == chatViewModel.messages.last, channel: channel, isShowingImageDetailView: $isShowingImageDetailView, detailImage: $detailImage)
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
                        }
                        .rotationEffect(Angle(degrees: 180))
                        .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                        
                        Color.clear
                            .onAppear {
                                Task {
                                    if let channel = channel {
                                        try await chatViewModel.addListener(channelID: channel.id)
                                    }
                                }
                            }
                    }
                }
                .rotationEffect(Angle(degrees: 180))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .onChange(of: chatViewModel.messages) { message in
                    Task {
                        if let channel {
                            try await chatViewModel.resetUnreadCount(channelID: channel.id)
                        }
                    }
                }
                
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
                    //task로 변경해주기~
                    if tradeState == .trading {
                        tradeState = .finish
                    } else {
                        tradeState = .trading
                    }
                }
            }
            
            if isShowingCustomAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertView, viewType: .leaveChatRoom) {
                    Task {
                        print("채팅방 나가기")
                        if let channel, let lastMessage = chatViewModel.messages.last {
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
        .navigationTitle(otherUserNickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    
                    Button {
                        coordinator.reportType = .chatRoom
                        if let channel = channel {
                            coordinator.reportedObjectID = channel.id
                        }
                        coordinator.appendPath(.reportView)
                    } label: {
                        Label("채팅 신고하기", systemImage: "exclamationmark.bubble")
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
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .onAppear {
            Task {
                /// 채팅방 불러오기 (trade만 알때)
                if channel == nil, let trade {
                    channel = try await chatViewModel.getChannel(tradeID: trade.id)
                    imageData = try await chatViewModel.loadThumnailImage(containerID: trade.id, imagePath: trade.thumbnailImagePath)
                    tradeState = trade.tradeState
                    if let channel = channel {
                        try await chatViewModel.addListener(channelID: channel.id)
                    }
                }
                
                /// 채널만 알 때 ......
                if let channel = channel {
                    await chatViewModel.setOtherUserImage(channel: channel)
                    /// trade 불러오기
                    trade = try await chatViewModel.getTrade(channelID: channel.id)
                    
                    /// Trade 이미지 · 상태 확인
                    if let trade {
                        imageData = try await chatViewModel.loadThumnailImage(containerID: trade.id, imagePath: trade.thumbnailImagePath)
                        tradeState = trade.tradeState
                    }
                    
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
                Rectangle()
                    .fill(.gray400)
                    .frame(width: geometry.size.width / 3.5, height: 0.3)
                
                Spacer()
                
                Text(dateString)
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption1)
                
                Spacer()
                
                Rectangle()
                    .fill(.gray400)
                    .frame(width: geometry.size.width / 3.5, height: 0.3)
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
            
            /// 메시지 입력
            ZStack {
                Rectangle()
                    .fill(.gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                TextField("메시지 보내기", text: $message)
                    .foregroundStyle(.gray900)
                    .font(ANBDFont.Caption3)
                    .padding(15)
            }
            .frame(height: 40)
            
            /// 메시지 전송
            Button(action: {
                if !message.isEmpty {
                    sendMessage()
                    message = ""
                }
            }, label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .foregroundStyle(message == "" ? .gray400 : .accentColor)
                    .rotationEffect(.degrees(43))
            })
            .disabled(message.isEmpty)
        }
    }
}


// MARK: - 필요 함수 · 변수 모아두기
extension ChatDetailView {
    
    /// NavigationTitle
    private var otherUserNickname: String {
        guard let channel else {
            guard let trade else { return "Unknown-User" }
            return trade.writerNickname
        }
        return chatViewModel.getOtherUserNickname(channel: channel)
    }
    
    /// 메시지 전송 함수
    private func sendMessage() {
        let newMessage = Message(userID: chatViewModel.user.id, userNickname: chatViewModel.user.nickname, content: message)
        
        Task {
            /// 채널이 없을 때
            if channel == nil, let trade {
                let newChannel = Channel(participants: [trade.writerID, chatViewModel.user.id],
                                         participantNicknames: [trade.writerNickname, chatViewModel.user.nickname],
                                         lastMessage: "",
                                         lastSendDate: .now,
                                         lastSendId: chatViewModel.user.id,
                                         unreadCount: 0,
                                         tradeId: trade.id)
                
                channel = try await chatViewModel.makeChannel(channel: newChannel)
                
                if let channel {
                    try await chatViewModel.addListener(channelID: channel.id)
                    await chatViewModel.setOtherUserImage(channel: channel)
                }
            }
            
            /// 채널 생성 후
            if let channel = channel {
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
                if channel == nil, let trade {
                    let newChannel = Channel(participants: [trade.writerID, chatViewModel.user.id],
                                             participantNicknames: [trade.writerNickname, chatViewModel.user.nickname],
                                             lastMessage: "",
                                             lastSendDate: .now,
                                             lastSendId: chatViewModel.user.id,
                                             unreadCount: 0,
                                             tradeId: trade.id)
                    
                    channel = try await chatViewModel.makeChannel(channel: newChannel)
                    
                    if let channel {
                        try await chatViewModel.addListener(channelID: channel.id)
                        await chatViewModel.setOtherUserImage(channel: channel)
                    }
                }
                
                /// 채널 있
                if let channel = channel {
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
