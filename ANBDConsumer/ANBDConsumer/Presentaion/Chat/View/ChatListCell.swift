//
//  ChatListCell.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct ChatListCell: View {
    var userNickname: String = "죠니"
    var lastMessage: String = "운관님 정말 채팅 진짜 잘 만드셨어요 ㄷ..ㄷ"
    var lastDate: String = "4월 15일"
    var unreadMessageCount: Int = 13
    
    var body: some View {
        HStack {
            /// 유저 프로필
            ZStack {
                Circle()
                    .fill(Color.gray100)
                    .frame(width: 50)
                
                Text("🐳")
                    .font(.system(size: 30))
            }
            .padding(.trailing, 10)
            
            /// 유저 닉넴 · 마지막 메시지
            VStack(alignment: .leading) {
                Text(userNickname)
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.SubTitle2)
                    .padding(.vertical, 2)
                
                Spacer()
                
                Text(lastMessage)
                    .lineLimit(1)
                    .foregroundStyle(Color.gray400)
                    .font(ANBDFont.body2)
            }
            .padding(.vertical, 13)
            
            Spacer()
            
            /// 날짜 · 뱃지
            VStack(alignment: .trailing) {
                Text(lastDate)
                    .foregroundStyle(Color.gray400)
                    .font(ANBDFont.Caption1)
                
                Spacer()
                
                if unreadMessageCount > 0 {
                    unreadMessageBage
                }
            }
            .padding(.vertical, 13)
        }
        .frame(height: 60)
    }
    
    /// 안읽은 메시지 뱃지
    private var unreadMessageBage: some View {
        Text("\(unreadMessageCount)")
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
        ChatListCell()
            .padding(.vertical, 5)
        ChatListCell(userNickname: "웅광당관운관운관당근운관", lastMessage: "운관님 꼬옥 중간고사 보세요 ... 파이팅 파이팅 이건 길게 써서 테스트 해봐야지 메롱메롱 짱메롱", lastDate: "12월 31일", unreadMessageCount: 100)
            .padding(.vertical, 5)
        ChatListCell(userNickname: "줄이", lastMessage: "줄이줄이 주리는 줄이 줄 주리 도넛꾸워", lastDate: "6월 1일", unreadMessageCount: 0)
            .padding(.vertical, 5)
        ChatListCell(userNickname: "마루", lastMessage: "짧테", lastDate: "3월 31일", unreadMessageCount: 1)
            .padding(.vertical, 5)
        ChatListCell(userNickname: "짱표", lastMessage: "짱표는 3대 400", lastDate: "9월 11일", unreadMessageCount: 0)
            .padding(.vertical, 5)
        ChatListCell(userNickname: "호맨vs호빵맨", lastMessage: "호맨은 호맨 호빵맨 의존성 쩌러", lastDate: "1월 1일", unreadMessageCount: 0)
            .padding(.vertical, 5)
        ChatListCell(userNickname: "시미시미", lastMessage: "시미시미열시미짱시미 열시미 구웃", lastDate: "7월 7일", unreadMessageCount: 90)
            .padding(.vertical, 5)
    }
    .padding(20)
}
