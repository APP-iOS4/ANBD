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
    
    @Published var chatPath: NavigationPath = NavigationPath()
    @Published var reportType: ReportType = .chatRoom
    @Published var reportedObjectID: String = ""
    @Published var reportedChannelID: String?
    
    private let chatUsecase: ChatUsecase = ChatUsecase()
    private let storageManager = StorageManager.shared
    
    @Published var user: User?
    @Published var chatRooms: [Channel] = []
    @Published var messages: [Message] = []
    @Published var otherUserLastMessages: [Message] = []
    @Published var otherUserProfileImageUrl: String = ""
    @Published var totalUnreadCount: Int = 0
    
    @Published var groupedMessages: [(day:String , messages:[Message])] = []
    
    private var isListener: Bool = false
    private var isLeaveChatRoom: Bool = false
    
    /// UserDefaults에서 유저 정보 불러오기
    func loadUserInfo() {
        self.user = UserStore.shared.user
    }
    
    
    /// fetch + listener
    func addListener(channelID: String) async throws {
        do {
            if let user {
                if !isLeaveChatRoom {
                    var preMessages = try await chatUsecase.loadMessageList(channelID: channelID, userID: user.id)
                    if let leaveMessageIndex = preMessages.lastIndex(where: { $0.leaveUsers.contains(user.id) }) {
                        isLeaveChatRoom = true
                        preMessages.removeSubrange(0...leaveMessageIndex)
                    }
                    self.messages.insert(contentsOf: preMessages, at: 0)
                    updateGroupedMessagesByDate()
                    updateLastMessage()
                }
                
                if !isListener {
                    if let lastMessage = messages.last {
                        try await chatUsecase.updateMessageReadStatus(channelID: channelID, lastMessage: lastMessage, userID: user.id)
                    }
                    
                    isListener = true
                    chatUsecase.listenNewMessage(channelID: channelID, userID: user.id) { [weak self] message in
                        if let lastMessageID = self?.messages.last?.id, lastMessageID == message.id, let lastIndex = self?.messages.indices.last {
                            /// 읽음 처리
                            self?.messages[lastIndex].isRead = true
                        } else {
                            /// 메시지 전송 (추가)
                            self?.messages.append(message)
                            self?.addMessageUpdate(addMessage: message)
                        }
                        self?.updateGroupedMessagesByDate()
                    }
                }
            }
        } catch {
            print("addListener ERROR: \(error)")
        }
    }
    
    private func updateGroupedMessagesByDate() {
        let messages = self.messages
        let groupDictionary = Dictionary(grouping: messages) { message in
            message.dateStringWithYear
        }
        let messageGroup = groupDictionary.map { key, value in
            let sortedMessages = value.sorted {$0.createdAt > $1.createdAt}
            return (day: key , messages: sortedMessages)
        }.sorted { $0.day > $1.day }
        
        self.groupedMessages = messageGroup
        
    }
    
    
    
    /// 전체 채팅방 리스트 불러오기
    func fetchChatRooms() {
        if let user {
            chatUsecase.loadChannelList(userID: user.id) { [weak self] channel in
                self?.chatRooms = channel
                self?.getTotalUnreadCount()
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
    
    func getOtherUserImage(channel: Channel) async {
        
        guard let user = user else {
            return
        }
        do {
            let otherUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            self.otherUserProfileImageUrl = otherUser.profileImage
        } catch {
            print("error: \(error)")
        }
    }
    
    func setOtherUserImage(channel: Channel) async -> String? {
        
        guard let user = user else {
            return nil
        }
        do {
            let otherUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            return otherUser.profileImage
        } catch {
            print("error: \(error)")
            return nil
        }
    }
    
    func updateLastMessage() {
        var otherMessages: [Message] = []
        
        guard let user = user else {
            return
        }
        for message in messages {
            if message.userID != user.id {
                if let lastMessage = otherMessages.last, lastMessage.dateStringWithYear != message.dateStringWithYear {
                    self.otherUserLastMessages.append(lastMessage)
                    otherMessages = []
                }
                otherMessages.append(message)
            } else {
                if let lastMessage = otherMessages.last {
                    self.otherUserLastMessages.append(lastMessage)
                    otherMessages = []
                }
            }
        }
        
        if let lastMessage = otherMessages.last {
            self.otherUserLastMessages.append(lastMessage)
        }
    }
    
    func addMessageUpdate(addMessage: Message) {
        if let lastMessage = otherUserLastMessages.last , lastMessage.dateStringWithYear == addMessage.dateStringWithYear{
            otherUserLastMessages.removeLast()
        }
        otherUserLastMessages.append(addMessage)
    }
    
    func getTotalUnreadCount(){
        totalUnreadCount = self.chatRooms.reduce(0) { result, channel in
            if channel.lastSendId != user?.id {
                return result + channel.unreadCount
            } else {
                return result + 0
            }
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
    
    /// 메시지 사진 로드
    func downloadImageUrl(messageID: String, imagePath: String) async throws -> URL? {
        do {
            return try await storageManager.downloadImageToUrl(path: .chat, containerID: messageID, imagePath: imagePath)
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
        isListener = false
        isLeaveChatRoom = false
        chatUsecase.initializeListener()
        messages = []
        groupedMessages = []
    }
    
    
    /// 채널 리스너 해제
    func resetChannelListener() {
        chatUsecase.initializeChannelsListener()
    }
    
    /// 채팅방 나가기
    func leaveChatRoom(channelID: String, lastMessageID: String) async throws {
        do {
            if let user {
                try await chatUsecase.leaveChatRoom(channelID: channelID, lastMessageID: lastMessageID, userID: user.id)
            }
        } catch {
            print("leaveChatRoom ERROR: \(error)")
        }
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


