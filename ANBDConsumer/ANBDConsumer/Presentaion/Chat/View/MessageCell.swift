//
//  ChatDetailView+Extension.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/19/24.
//

import SwiftUI
import ANBDModel

extension ChatDetailView {
    struct MessageCell: View {
        @EnvironmentObject private var homeViewModel: HomeViewModel
        @EnvironmentObject private var tradeViewModel: TradeViewModel
        @EnvironmentObject private var chatViewModel: ChatViewModel
        @Environment(\.colorScheme) private var colorScheme: ColorScheme
        
        var message: Message
        var isLast: Bool = false
        @State var imageData: Data?
        @State private var isMine: Bool = false
        var anbdViewType: ANBDViewType = .chat
        var channelID: String
        
        @Binding var isShowingImageDetailView: Bool
        @Binding var detailImage: Image
        
        var body: some View {
            HStack(alignment: .bottom) {
                if isMine {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if isLast {
                            Text(message.isRead ? "읽음" : "전송됨")
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
                        .contextMenu {
                            Button("메시지 신고하기", role: .destructive) {
                                homeViewModel.reportType = .messages
                                chatViewModel.reportType = .messages
                                
                                homeViewModel.reportedObjectID = message.id
                                chatViewModel.reportedObjectID = message.id
                                
                                homeViewModel.reportedChannelID = channelID
                                chatViewModel.reportedChannelID = channelID
                                
                                switch anbdViewType {
                                case .home:
                                    homeViewModel.homePath.append(ANBDNavigationPaths.reportView)
                                case .trade:
                                    tradeViewModel.tradePath.append(ANBDNavigationPaths.reportView)
                                case .chat:
                                    chatViewModel.chatPath.append(ANBDNavigationPaths.reportView)
                                }
                            }
                        }
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
                        .contextMenu {
                            Button("메시지 신고하기", role: .destructive) {
                                homeViewModel.reportType = .messages
                                chatViewModel.reportType = .messages
                                
                                switch anbdViewType {
                                case .home:
                                    homeViewModel.homePath.append(ANBDNavigationPaths.reportView)
                                case .trade:
                                    tradeViewModel.tradePath.append(ANBDNavigationPaths.reportView)
                                case .chat:
                                    chatViewModel.chatPath.append(ANBDNavigationPaths.reportView)
                                }
                            }
                        }
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
                if let user = chatViewModel.user {
                    isMine = message.userID == user.id
                }
                
                if let imagePath = message.imagePath {
                    Task {
                        /// 이미지 로드
                        imageData = try await chatViewModel.downloadImagePath(messageID: message.id, imagePath: imagePath)
                    }
                }
            }
        }
    }
}
