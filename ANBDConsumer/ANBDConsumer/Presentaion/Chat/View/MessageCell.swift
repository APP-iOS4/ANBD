//
//  ChatDetailView+Extension.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/19/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct MessageCell: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var message: Message
    var isLast: Bool = false
    @State var imageUrl: URL?
    @State private var isMine: Bool = false
    
    var channel: Channel
    
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
            
            if !isMine && chatViewModel.otherUserLastMessages.contains(message){
                ZStack {
                    CachedAsyncImage(url: URL(string: chatViewModel.otherUserProfileImageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 30)
                }
            }else if !isMine {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 30)
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
                        if !isMine {
                            Button("메시지 신고하기", role: .destructive) {
                                coordinator.reportType = .messages
                                coordinator.reportedObjectID = message.id
                                coordinator.reportedChannelID = channel.id
                                coordinator.appendPath(.reportView)
                            }
                        }
                    }
            }
            
            // 이미지
            if let imageUrl {
                CachedAsyncImage(url: imageUrl) { image in
                    Button(action: {
                        detailImage = image
                        isShowingImageDetailView.toggle()
                    }, label: {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    })
                    .contextMenu {
                        if !isMine {
                            Button("메시지 신고하기", role: .destructive) {
                                coordinator.reportType = .messages
                                coordinator.reportedObjectID = message.id
                                coordinator.reportedChannelID = channel.id
                                coordinator.appendPath(.reportView)
                            }
                        }
                    }
                } placeholder: {
                    ProgressView()
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
            isMine = message.userID == chatViewModel.user.id
            
            if let imagePath = message.imagePath {
                Task {
                    /// 이미지 로드
                    imageUrl = try await chatViewModel.downloadImageUrl(messageID: message.id, imagePath: imagePath)
                }
            }
        }
    }
}
