//
//  ChatViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import ANBDModel

@MainActor
final class ChatViewModel: ObservableObject {
    
    let userID: String = "A414DC19-A424-4FB8-88E7-B23B06EB67A7"
    let userNickname: String = "테스트관2"
    private let chatUsecase: ChatUsecase = ChatUsecase()
    
    @Published var chatRooms: [Channel] = []
    @Published var messages: [Message] = []
    
    /// 전체 채팅방 리스트 불러오기
    func fetchChatRooms() {
        chatUsecase.loadChannelList(userID: userID) { [weak self] channel in
            self?.chatRooms = channel
        }
    }
    
    /// 채팅방 메시지 불러오기 : 20개씩 페이지네이션
    func fetchMessages(channelID: String) async throws {
        do {
            let preMessages = try await chatUsecase.loadMessageList(channelID: channelID, userID: userID)
            self.messages.insert(contentsOf: preMessages, at: 0)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// 메시지 리스너 (실시간 채팅 확인 - 읽음·안읽음, 추가)
    func addMessageListener(channelID: String) {
        chatUsecase.listenNewMessage(channelID: channelID, userID: userID) { [weak self] message in
            if let lastMessageID = self?.messages.last?.id, lastMessageID == message.id, let lastIndex = self?.messages.indices.last {
                /// 읽음 처리
                self?.messages[lastIndex].isRead = true
            } else {
                /// 메시지 전송 (추가)
                self?.messages.append(message)
            }
        }
    }
    
    /// 채널 생성 (처음 채팅을 남길 때) : ChannelID 반환
    func makeChannel(channel: Channel) async throws -> String {
        do {
            return try await chatUsecase.createChannel(channel: channel)
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
    
    /// 채팅방 Trade 가져오기
    func getTrade(channelID: String) async throws -> Trade? {
        do {
            return try await chatUsecase.getTradeInChannel(channelID: channelID)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    /// 메시지 보내기 (Text)
    func sendMessage(message: Message, channelID: String) async throws {
        do {
            try await chatUsecase.sendMessage(message: message, channelID: channelID)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// 메시지 보내기 (Image)
    func sendImageMessage(message: Message, imageData: Data, channelID: String) async throws {
        do {
            try await chatUsecase.sendImageMessage(message: message, imageData: imageData, channelID: channelID)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// 채팅방 onDisappear시, 메시지 데이터 초기화
    func resetMessageData() {
        chatUsecase.initializeListener()
        messages = []
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
