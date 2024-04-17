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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    /// 채팅방 구분 변수
    @State var channel: Channel? = nil
    @State var trade: Trade? = nil
    @State private var tradeState: TradeState = .trading
    @State private var isDeleted: Bool = false
    
    /// 보낼 메시지 관련 변수
    @State private var message: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedPhoto: Data?
    
    /// Sheet 관련 변수
    @State private var isShowingConfirmSheet: Bool = false
    @State private var isShowingCustomAlertView: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var detailImage: Image = Image("DummyPuppy3")
    @State private var isGoingToReportView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                messageHeaderView
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                
                Divider()
                
                /// message 내역
                ScrollView {
                    LazyVStack {
                        ForEach(chatViewModel.messages.reversed()) { message in
                            MessageCellStruct(message: message, isShowingImageDetailView: $isShowingImageDetailView, detailImage: $detailImage)
                                .padding(.vertical, 1)
                                .padding(.horizontal, 20)
//                            MessageCell(message: message)
//                                .padding(.vertical, 1)
//                                .padding(.horizontal, 20)
                        }
                        .rotationEffect(Angle(degrees: 180))
                        .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                        
                        Color.clear
                            .onAppear {
                                Task {
                                    if let channel = channel {
                                        try await chatViewModel.fetchMessages(channelID: channel.id)
                                    }
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
                    print("채팅방 나가기 ~~")
                    dismiss()
                }
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingConfirmSheet.toggle()
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                })
            }
        }
        .confirmationDialog("", isPresented: $isShowingConfirmSheet) {
            Button("채팅 신고하기", role: .destructive) {
                isGoingToReportView.toggle()
            }
            
            Button("채팅방 나가기", role: .destructive) {
                isShowingCustomAlertView.toggle()
            }
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .chat)
        }
        .onAppear {
            Task {
                /// 채팅방 불러오기
                if channel == nil, let trade {
                    channel = try await chatViewModel.getChannel(tradeID: trade.id)
                }
                
                if let channel = channel {
                    chatViewModel.addMessageListener(channelID: channel.id)
                    trade = try await chatViewModel.getTrade(channelID: channel.id)
                    
                    /// Trade 상태 확인
                    if trade != nil {
                        tradeState = trade?.tradeState ?? TradeState.trading
                    }
                    
                    /// 안읽음 메시지 개수 갱신
                    try await chatViewModel.resetUnreadCount(channelID: channel.id)
                }
                
                /// 가져온 Trade 확인
                if trade == nil {
                    /// 삭제된 Trade
                    isDeleted = true
                }
            }
        }
        .onDisappear {
            chatViewModel.resetMessageData()
        }
    }
    
    // MARK: - 메시지 해더 뷰 (Trade 관련)
    // TODO: ProgressView 필요 ... 합니다 ㅠㅠ
    private var messageHeaderView: some View {
        HStack {
            if isDeleted {
                Image(systemName: "exclamationmark.square.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 10)
                    .foregroundStyle(.gray500)
            } else {
                // 여기서 !!!!! -> Image ProgressView
                Image("DummyImage1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
            }
            
            VStack(alignment: .leading) {
                Text(isDeleted ? "삭제된 게시물" : trade?.title ?? "Unknown")
                    .lineLimit(1)
                    .font(ANBDFont.SubTitle3)
                
                Spacer()
                Text(tradeProductString)
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption3)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            if !isDeleted {
                VStack(alignment: .leading) {
                    // TODO: TradeStateChangeView 수정해야 함 : tradeState 매개변수가 아니라 trade 전체 넘겨주기 
                    TradeStateChangeView(tradeState: $tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .frame(height: 70)
        .foregroundStyle(.gray900)
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

// MARK: - 메시지 Cell
extension ChatDetailView {
    struct MessageCellStruct: View {
        @EnvironmentObject private var chatViewModel: ChatViewModel
        @State private var isMine: Bool = false
        var message: Message
        var isRead: Bool?
        @State var imageData: Data?
        @Environment(\.colorScheme) private var colorScheme: ColorScheme
        @Binding var isShowingImageDetailView: Bool
        @Binding var detailImage: Image
        
        var body: some View {
            HStack(alignment: .bottom) {
                if isMine {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if let isRead = isRead {
                            Text(isRead ? "읽음" : "전송됨")
                                .padding(.vertical, 1)
                        }
                        Text("\(message.dateString)")
                    }
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption2)
                }
                
                // 텍스트
                if let content = message.content {
                    Text(content)
                        .padding(15)
                        .foregroundStyle(isMine ? .white : (colorScheme == .dark ? Color(red: 13/255, green: 15/255, blue: 20/255) : .gray900))
                        .font(ANBDFont.Caption3)
                        .background(isMine ? Color.accentColor : .gray50)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                // 이미지
                if let imageData {
                    if let uiImage = UIImage(data: imageData) {
                        Button(action: {
                            detailImage = Image(uiImage: uiImage)
                            isShowingImageDetailView.toggle()
                        }, label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        })
                    }
                }
                
                if !isMine {
                    Text("\(message.dateString)")
                        .foregroundStyle(.gray400)
                        .font(ANBDFont.Caption2)
                    
                    Spacer()
                }
            }
            .onAppear {
                isMine = message.userID == chatViewModel.userID
                
                if let imagePath = message.imagePath {
                    Task {
                        /// 이미지 로드
                        imageData = try await chatViewModel.downloadImagePath(messageID: message.id, imagePath: imagePath)
                    }
                }
            }
        }
    }
    
    
//    @ViewBuilder
    private func MessageCell(message: Message, isRead: Bool? = nil) -> some View {
        let isMine: Bool = message.userID == chatViewModel.userID
        @State var imageData: Data?
        
        return HStack(alignment: .bottom) {
            if isMine {
                Spacer()
                
                VStack(alignment: .trailing) {
                    if let isRead = isRead {
                        Text(isRead ? "읽음" : "전송됨")
                            .padding(.vertical, 1)
                    }
                    Text("\(message.dateString)")
                }
                .foregroundStyle(.gray400)
                .font(ANBDFont.Caption2)
            }
            
            // 텍스트
            if let content = message.content {
                Text(content)
                    .padding(15)
                    .foregroundStyle(isMine ? .white : (colorScheme == .dark ? Color(red: 13/255, green: 15/255, blue: 20/255) : .gray900))
                    .font(ANBDFont.Caption3)
                    .background(isMine ? Color.accentColor : .gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            // 이미지
            if let imageData {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            
            if !isMine {
                Text("\(message.dateString)")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption2)
                
                Spacer()
            }
        }
        .onAppear {
            if let imagePath = message.imagePath {
                Task {
                    /// 이미지 로드
                    imageData = try await chatViewModel.downloadImagePath(messageID: message.id, imagePath: imagePath)
                }
            }
        }
    }
}

// MARK: - 필요 함수 · 변수 모아두기
extension ChatDetailView {
    /// Trade 상품 String
    private var tradeProductString: String {
        if isDeleted {
            return "글쓴이가 삭제한 게시물이에요."
        } else {
            if let trade = trade {
                if trade.category == .nanua {
                    return trade.myProduct
                } else if trade.category == .baccua {
                    return "\(trade.myProduct) ↔ \(trade.wantProduct ?? "제시")"
                }
            }
            return ""
        }
    }
    
    /// 메시지 전송 함수
    private func sendMessage() {
        let newMessage = Message(userID: chatViewModel.userID, userNickname: chatViewModel.userNickname, content: message)
        
        Task {
            /// 채널이 없을 때
            if channel == nil, let trade {
                let newChannel = Channel(participants: [trade.writerID, chatViewModel.userID],
                                         participantNicknames: [trade.writerNickname, chatViewModel.userNickname],
                                         lastMessage: "",
                                         lastSendDate: .now,
                                         lastSendId: chatViewModel.userID,
                                         unreadCount: 0,
                                         tradeId: trade.id)
                
                channel = try await chatViewModel.makeChannel(channel: newChannel)
                
                if let channel {
                    chatViewModel.addMessageListener(channelID: channel.id)
                }
            }
            
            /// 채널 생성 후
            if let channel = channel {
                print(channel.id)
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
            
            let newMessage = Message(userID: chatViewModel.userID, userNickname: chatViewModel.userNickname)
            if let imageData = selectedPhoto {
                /// 채널이 없을 때
                if channel == nil, let trade {
                    let newChannel = Channel(participants: [trade.writerID, chatViewModel.userID],
                                             participantNicknames: [trade.writerNickname, chatViewModel.userNickname],
                                             lastMessage: "",
                                             lastSendDate: .now,
                                             lastSendId: chatViewModel.userID,
                                             unreadCount: 0,
                                             tradeId: trade.id)
                    
                    channel = try await chatViewModel.makeChannel(channel: newChannel)
                    
                    if let channel {
                        chatViewModel.addMessageListener(channelID: channel.id)
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
