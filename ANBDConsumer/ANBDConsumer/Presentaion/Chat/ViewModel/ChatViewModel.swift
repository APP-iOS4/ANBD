//
//  ChatViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import ANBDModel

final class ChatViewModel: ObservableObject {
    
    private let userID: String = "A414DC19-A424-4FB8-88E7-B23B06EB67A7"
    private let userNickname: String = "테스트관2"
    private let chatUsecase: ChatUsecase = ChatUsecase()
    
    @Published var chatRooms: [Channel] = []
    @Published var messages: [Message] = []
    
    /// 전체 채팅방 리스트 불러오기
    func fetchChatRooms() {
        chatUsecase.loadChannelList(userID: userID) { [weak self] channel in
            self?.chatRooms = channel
        }
    }
    
    /// 상대방 닉네임 불러오기
    func getOtherUserNickname(channel: Channel) -> String {
        return chatUsecase.getOtherUserNickname(userNicknames: channel.userNicknames, userNickname: userNickname)
    }
    
    /// 채팅방 쌓인 메시지 개수 불러오기
    func getUnreadCount(channel: Channel) -> Int {
        var cnt = 0
        if channel.lastSendId != userID {
            cnt = channel.unreadCount
        }
        return cnt
    }
}
