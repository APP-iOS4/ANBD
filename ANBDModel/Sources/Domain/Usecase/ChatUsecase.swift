//
//  File.swift
//
//
//  Created by 정운관 on 4/6/24.
//

import Foundation
import FirebaseAuth
import UIKit

@available(iOS 15, *)
public protocol ChatUsecaseProtocol {
    func createChannel(channel : Channel) async throws -> Channel
    func loadChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void)
    func loadMessageList(channelID: String, userID: String ) async throws -> [Message]
    func getChannel(tradeID : String , userID: String) async throws -> Channel?
    func getChannel(channelID: String) async throws -> Channel?
    func getMessage(channelID: String, messageID: String ) async throws -> Message
    func getTradeInChannel(channelID: String)  async throws -> Trade?
    func getOtherUserNickname(userNicknames: [String], userNickname : String) -> String
    func getOtherUserID(users: [String], userID: String) -> String
    func getOtherUser(channel : Channel , userID: String) async throws -> User
    func listenNewMessage(channelID: String ,userID: String ,completion: @escaping ((Message) -> Void))
    func sendMessage(message: Message , channelID: String) async throws
    func sendImageMessage(message: Message, imageData: Data ,channelID:String) async throws
    func updateUnreadCount(channelID: String , userID: String) async throws
    func updateActiveUser(channelID: String,userID: String , into: Bool) async throws
    func loadActiveUser(channelID: String) async throws -> [String]
    func leaveChatRoom(channelID: String , lastMessageID: String, userID: String) async throws
    func downloadImage(messageID : String , imagePath : String) async throws -> Data
    func initializeListener()
    func initializeChannelsListener()
}

@available(iOS 15, *)
public struct ChatUsecase : ChatUsecaseProtocol {

    private let chatRepository: ChatRepository = DefaultChatRepository()
    private let messageRepository : MessageRepository = DefaultMessageRepository()
    private let userRepository : UserRepository = DefaultUserRepository()
    
    private let storage = StorageManager.shared
    
    public init() {}
    
    //채널 생성
    //sendMessage or sendImage을 할때 현재 생성된 채널ID가 ""이면 채널 생성
    ///
    /// - Parameters:
    ///   - channel: 새로 추가할려는 채널
    /// - Returns: 새로 생성된 채널ID
    public func createChannel(channel: Channel) async throws -> Channel{
        if channel.id.isEmpty {
            throw ChannelError.invalidChannelID
        }
        return try await chatRepository.createChannel(channel: channel)
    }
    
    //채팅방 리스트탭에서 채팅방 목록 불러오기
    ///
    /// - Parameters:
    ///   - userID: 현재 내 ID
    /// - Returns: 내 ID로 생성된 채널 List
    public func loadChannelList(userID: String, completion :@escaping (_ channels: [Channel]) -> Void) {
        chatRepository.readChannelList(userID: userID) { channels in
            completion(channels)
        }
    }
    
    //이미 채팅 내역이 있는 게시글에서 다시 채팅하기 버튼을 눌렀을 경우 채팅 목록이 불러오기 위해 채널 ID를 불러오는 메소드
    //게시글을 통해 채팅방에 들어왔을때 생성된 채널 ID가 있는지 체크
    ///
    /// - Parameters:
    ///   - tradeID: 현재 들어간 trade 게시글 ID
    ///   - userID : 내 ID
    /// - Returns: 채널 ID
    public func getChannel(tradeID: String, userID: String) async throws -> Channel? {
        if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        } else if tradeID.isEmpty {
            throw TradeError.invalidTradeIDField
        }
        
        return try await chatRepository.readChannel(tradeID: tradeID, userID: userID)
    }
    
    public func getChannel(channelID: String) async throws -> Channel? {
        return try await chatRepository.readChannel(channelID: channelID)
    }
    
    
    //채팅방 리스트에서 상대방 닉네임을 보여줘야 할때
    ///
    /// - Parameters:
    ///   - userNicknames: 현재 채널의 유저 닉네임들
    ///   - userNickname : 내 닉네임
    /// - Returns: 상대방 닉네임
    public func getOtherUserNickname(userNicknames: [String], userNickname: String) -> String {
        guard let index = userNicknames.firstIndex(of: userNickname) else {
            return "상대방을 찾을수 없습니다"
        }
        return userNicknames[(index+1) % 2]
    }
    
    //채팅방 리스트에서 상대방 id를 얻는법 (프로필 이미지 얻기 위해서?)
    ///
    /// - Parameters:
    ///   - users: 현재 채널의 유저들
    ///   - userID: 내 ID
    /// - Returns: 상대방 ID
    public func getOtherUserID(users: [String], userID: String) -> String {
        guard let index = users.firstIndex(of: userID) else {
            return "상대방을 찾을수 없습니다"
        }
        return users[(index+1) % 2]
    }
    
    //채팅방 리스트에서 상대방 user 정보를 얻는법 (프로필 이미지 얻기 위해서?)
    ///
    /// - Parameters:
    ///   - channel: 현재 채널
    ///   - userID: 내 ID
    /// - Returns: 상대방 User 정보
    public func getOtherUser(channel: Channel, userID: String) async throws -> User {
        if channel.id.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        let otherUserID = getOtherUserID(users: channel.users, userID: userID)
        return try await userRepository.readUserInfo(userID: otherUserID)
    }

    //채팅방 리스트에서 채팅방을 들어갔을때 채팅방 상단에 게시글의 정보가 보여야하기 때문에 채널 ID로 Trade 정보를 얻는 메소드
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    /// - Returns: Trade
    public func getTradeInChannel(channelID: String) async throws -> Trade? {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        }
        return try await chatRepository.readTradeInChannel(channelID: channelID)
    }
    
    //안읽은 메시지 수 업데이트하는 메소드
    //채팅방뷰에서 onAppear,onDisappear에서 사용
    ///
    /// - Parameters:
    ///   - channelID: 현재 채팅방 채널ID
    ///   - userID: 내 ID
    public func updateUnreadCount(channelID: String, userID: String) async throws {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        
        try await chatRepository.updateUnreadCount(channelID: channelID, userID: userID)
    }
    
    public func updateActiveUser(channelID: String, userID: String , into: Bool) async throws {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        if into {
            try await chatRepository.updateActiveUser(channelID: channelID, userID: userID)
        } else {
            try await chatRepository.deleteActiveUser(channelID: channelID, userID: userID)
        }
    }
    
    public func loadActiveUser(channelID: String) async throws -> [String] {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        }
        return try await chatRepository.readActiveUsers(channelID: channelID)
    }
    
    //채팅방 나가기
    ///
    /// - Parameters:
    ///   - channelID: 현재 채팅방 채널ID
    ///   - userID: 내 ID
    public func leaveChatRoom(channelID: String, lastMessageID: String, userID: String) async throws {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        
        try await chatRepository.updateLeftChatUser(channelID: channelID, lastMessageID: lastMessageID, userID: userID)
        
        if try await chatRepository.readLeftBothUser(channelID: channelID) {
            try await chatRepository.deleteChannel(channelID: channelID)
            try await messageRepository.deleteMessageList(channelId: channelID)
        }
    }
    
    public func initializeChannelsListener() {
        chatRepository.deleteListener()
    }
    
    //이미지 다운로드
    public func downloadImage(messageID : String , imagePath : String) async throws -> Data{
        if imagePath.isEmpty {
           throw StorageError.invalidImagePath
        }
        
        return try await storage.downloadImage(path: .chat, containerID: messageID, imagePath: imagePath)
    }
}

// MARK: - 메시지 관련 메소드
@available(iOS 15, *)
extension ChatUsecase {
    //최초로 채팅방 들어가면 보이는 채팅 목록들 불러오기
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    ///   - userID : 내 ID
    /// - Returns: 채널 ID에 해당하는 채팅방 메시지 목록들
    ///
    public func loadMessageList(channelID: String, userID: String) async throws -> [Message] {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        
        return try await messageRepository.readMessageList(channelID: channelID, userID: userID)
    }
    
    //원하는 메시지 정보 불러오기
    ///
    /// - Parameters:
    ///   - channelID: 채널 ID
    ///   - messageID : 메시지 ID
    /// - Returns: 메시지
    ///
    public func getMessage(channelID: String, messageID: String) async throws -> Message {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        }
        return try await messageRepository.readMessage(channelID: channelID, messageID: messageID)
    }
    
    //채팅방 들어가면 새롭게 추가되는 채팅들에 대한 Listner
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    /// - Returns: 새롭게 추가된 메세지
    ///
    public func listenNewMessage(channelID: String, userID : String ,completion: @escaping ((Message) -> Void)) {
        messageRepository.readNewMessage(channelID: channelID , userID: userID) { message in
            completion(message)
        }
    }
    
    //메세지를 보내는 메소드
    ///
    /// - Parameters:
    ///   - message: 보내려는 메시지(imagePath는 입력 x)
    ///   - channelID : 메시지를 보내려는 채널 ID
    public func sendMessage(message: Message, channelID: String) async throws {
        if channelID.isEmpty {
            throw MessageError.invalidChannelID
        }
        
        try await chatRepository.updateChannel(message: message, channelID: channelID)
        try await messageRepository.createMessage(message: message, channelID: channelID)
    }
    
    //이미지 메시지를 보내는 메소드
    ///
    /// - Parameters:
    ///   - message: 보내려는 메시지(content는 입력 x)
    ///   - imageData: 보내려는 이미지 데이터
    ///   - channelID : 메시지를 보내려는 채널 ID
    public func sendImageMessage(message: Message, imageData: Data, channelID: String) async throws {
        if channelID.isEmpty {
            throw MessageError.invalidChannelID
        }
        
        var newMessage = message
        let imageData = await UIImage(data: imageData)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
        if let imageData {
            newMessage.imagePath = try await storage.uploadImage(path: .chat, containerID: message.id, imageData: imageData)
        }
        try await sendMessage(message: newMessage, channelID: channelID)
    }
    
    //채팅방에 들어갈때 최초로 한번 안읽었던 메시지에 대한 읽음 처리
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    ///   - message : 현재 들어간 채팅방의 마지막 메시지
    ///   - userID: 내 아이디
    ///
    public func updateMessageReadStatus(channelID: String, lastMessage: Message, userID: String) async throws {
        if channelID.isEmpty {
            throw ChannelError.invalidChannelID
        } else if userID.isEmpty {
            throw ChannelError.invalidUserInfo
        }
        
        try await messageRepository.updateMessageReadStatus(channelID: channelID, lastMessage: lastMessage, userID: userID)
    }
    
    //채팅방 뷰에서 나갈때(Disappear) 할때 리스너 초기화 및 fetchData에 필요한 주소들 초기화하는 메소드
    public func initializeListener() {
        messageRepository.deleteListener()
    }
}
