//
//  ChatDetailView+Extension.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/19/24.
//

import SwiftUI
import Foundation
import ANBDModel
import Kingfisher

struct MessageCell: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var message: Message
    var isLast: Bool = false
    @State var imageUrl: URL?
    @State private var isMine: Bool = false
    @State private var isLoading: Bool = true
    
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
                    KFImage(URL(string: chatViewModel.selectedUser.profileImage))
                        .placeholder { _ in
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
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
                            Button(role: .destructive) {
                                coordinator.reportType = .messages
                                coordinator.reportedObjectID = message.id
                                coordinator.reportedChannelID = channel.id
                                coordinator.appendPath(.reportView)
                            } label: {
                                Label("메시지 신고하기", systemImage: "exclamationmark.bubble")
                            }

                        }
                    }
            }
            
            // 이미지
            if let imageUrl {
                Button {
                    Task {
                        let (data, _) = try await URLSession.shared.data(from: imageUrl)
                        detailImage = Image(uiImage: UIImage(data: data))
                        isShowingImageDetailView.toggle()
                    }
                } label: {
                    KFImage(imageUrl)
                        .placeholder { _ in
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .contextMenu {
                            if !isMine {
                                Button(role: .destructive) {
                                    coordinator.reportType = .messages
                                    coordinator.reportedObjectID = message.id
                                    coordinator.reportedChannelID = channel.id
                                    coordinator.appendPath(.reportView)
                                } label: {
                                    Label("메시지 신고하기", systemImage: "exclamationmark.bubble")
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
