//
//  ChatViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

@MainActor
final class ChatViewModel: ObservableObject {
    
    private let chatUsecase: ChatUsecase = ChatUsecase()
    private let storageManager = StorageManager.shared
    
    @Published var user: User?
    @Published var chatRooms: [Channel] = []
    @Published var messages: [Message] = []
    
    var isListener: Bool = false
    
    /// UserDefaults에서 유저 정보 불러오기
    func loadUserInfo() {
        if let user = UserDefaultsClient.shared.userInfo {
            self.user = user
        }
    }
    
    
    /// fetch + listener
    func addListener(channelID: String) async throws {
        do {
            if let user {
                let preMessages = try await chatUsecase.loadMessageList(channelID: channelID, userID: user.id)
                self.messages.insert(contentsOf: preMessages, at: 0)
                
                if !isListener {
                    isListener = true
                    chatUsecase.listenNewMessage(channelID: channelID, userID: user.id) { [weak self] message in
                        self?.messages.append(message)
                    }
                }
            }
        } catch {
            print("addListener ERROR: \(error)")
        }
    }
    
    
    /// 전체 채팅방 리스트 불러오기
    func fetchChatRooms() {
        if let user {
            chatUsecase.loadChannelList(userID: user.id) { [weak self] channel in
                self?.chatRooms = channel
            }
        }
    }
    
    /// 채팅방 메시지 불러오기 : 20개씩 페이지네이션 
    func fetchMessages(channelID: String) async throws {
        do {
            if let user {
                let preMessages = try await chatUsecase.loadMessageList(channelID: channelID, userID: user.id)
                self.messages.insert(contentsOf: preMessages, at: 0)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// 메시지 리스너 (실시간 채팅 확인 - 읽음·안읽음, 추가)
    func addMessageListener(channelID: String) {
        if !isListener {
            if let user {
                isListener = true
                chatUsecase.listenNewMessage(channelID: channelID, userID: user.id) { [weak self] message in
                    self?.messages.append(message)
                    
        //            if let lastMessageID = self?.messages.last?.id, lastMessageID == message.id, let lastIndex = self?.messages.indices.last {
        //                /// 읽음 처리
        //                self?.messages[lastIndex].isRead = true
        //            } else {
        //                /// 메시지 전송 (추가)
        //                self?.messages.append(message)
        //            }
                }
            }
        }
    }
    
    /// 채널 생성 (처음 채팅을 남길 때) : ChannelID 반환
    func makeChannel(channel: Channel) async throws -> Channel {
        do {
            return try await chatUsecase.createChannel(channel: channel)
        } catch {
            print("Error: \(error)")
            return Channel(participants: [], participantNicknames: [], lastMessage: "", lastSendDate: .now, lastSendId: "", unreadCount: 0, tradeId: "")
        }
    }
    
    /// 채널 가져오기
    func getChannel(tradeID: String) async throws -> Channel? {
        do {
            if let user {
                return try await chatUsecase.getChannel(tradeID: tradeID, userID: user.id)
            }
            return nil
        } catch {
            print("getChannel Error: \(error)")
            return nil
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
    
    
    /// 이미지 다운로드
    func loadThumnailImage(containerID: String, imagePath: String) async throws -> Data {
        do {
            return try await storageManager.downloadImage(path: .trade, containerID: "\(containerID)/thumbnail", imagePath: imagePath)
        } catch {
            print("HomeViewModel Error loadImage : \(error) \(error.localizedDescription)")

            /// 이미지 예외 처리
            let image = UIImage(named: "ANBDWarning")
            let imageData = image?.pngData()
            return imageData ?? Data()
        }
    }
    
    /// 메시지 사진 로드
    func downloadImagePath(messageID: String, imagePath: String) async throws -> Data {
        do {
            return try await chatUsecase.downloadImage(messageID: messageID, imagePath: imagePath)
        } catch {
            print("Error: \(error)")
            return Data()
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
        isListener = false
        chatUsecase.initializeListener()
        messages = []
    }
    
    /// 안읽은 메시지 개수 초기화
    func resetUnreadCount(channelID: String) async throws {
        do {
            if let user {
                try await chatUsecase.updateUnreadCount(channelID: channelID, userID: user.id)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// 상대방 닉네임 불러오기
    func getOtherUserNickname(channel: Channel) -> String {
        if let user {
            return chatUsecase.getOtherUserNickname(userNicknames: channel.userNicknames, userNickname: user.nickname)
        }
        return "상대방 닉네임을 불러오지 못했습니다."
    }
    
    /// 채팅방 쌓인 메시지 개수 불러오기
    func getUnreadCount(channel: Channel) -> Int {
        var cnt = 0
        if let user, channel.lastSendId != user.id {
            cnt = channel.unreadCount
        }
        return cnt
    }
}
