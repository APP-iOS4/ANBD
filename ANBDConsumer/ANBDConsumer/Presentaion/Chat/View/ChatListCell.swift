//
//  ChatListCell.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import ANBDModel

struct ChatListCell: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    var channel: Channel
    
    var body: some View {
        HStack {
            /// 유저 프로필
            ZStack {
                Circle()
                    .fill(Color.gray100)
                    .frame(width: 55)
                
                Text("🐳")
                    .font(.system(size: 33))
            }
            .padding(.trailing, 10)
            
            /// 유저 닉넴 · 마지막 메시지
            VStack(alignment: .leading) {
                Text(chatViewModel.getOtherUserNickname(channel: channel))
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
