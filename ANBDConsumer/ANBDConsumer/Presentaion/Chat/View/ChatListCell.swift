//
//  ChatListCell.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct ChatListCell: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    var channel: Channel
    @State var otherUser: User?
    
    var body: some View {
        HStack {
            /// 유저 프로필
            if let otherUser {
                CachedAsyncImage(url: URL(string: otherUser.profileImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.2))
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 55 , height: 55)
                .padding(.trailing, 10)
                
                
                
                /// 유저 닉넴 · 마지막 메시지
                VStack(alignment: .leading) {
                    Text(otherUser.nickname)
                        .foregroundStyle(Color.gray900)
                        .font(ANBDFont.SubTitle2)
                    
                    Spacer()
                    
                    Text(channel.lastMessage)
                        .lineLimit(1)
                        .foregroundStyle(Color.gray400)
                        .font(ANBDFont.body2)
                }
                .padding(.vertical, 12)
                
                Spacer()
                
                /// 날짜 · 뱃지
                VStack(alignment: .trailing) {
                    Text(channel.lastDateString)
                        .foregroundStyle(Color.gray400)
                        .font(ANBDFont.Caption1)
                    
                    Spacer()
                    
                    if chatViewModel.getUnreadCount(channel: channel) > 0 {
                        unreadMessageBage
                    }
                }
                .padding(.vertical, 9)
            }
        }
        .onAppear {
            Task {
                otherUser = await chatViewModel.getOtherUserImage(channel:channel)
            }
            
        }
        .frame(height: 70)
    }
    
    /// 안읽은 메시지 뱃지
    private var unreadMessageBage: some View {
        Text("\(chatViewModel.getUnreadCount(channel: channel))")
            .foregroundStyle(.white)
            .font(ANBDFont.Caption1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.heartRed)
            .clipShape(RoundedRectangle(cornerRadius: 300))
    }
}

#Preview {
    VStack(alignment: .leading) {
        ChatListCell(channel: Channel(participants: [],
                                      participantNicknames: [],
                                      lastMessage: "String",
                                      lastSendDate: .now,
                                      lastSendId: "",
                                      unreadCount: 13,
                                      tradeId: ""))
        .padding(.vertical, 5)
    }
    .padding(20)
    .environmentObject(ChatViewModel())
}
