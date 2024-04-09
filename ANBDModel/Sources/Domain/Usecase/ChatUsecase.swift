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
    func createChannel(channel : Channel) async throws -> String
    func loadChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void)
    func loadChannelID(tradeID : String , userID: String) async throws -> String?
    func loadTradeInChannel(channelID: String)  async throws -> Trade?
    func loadOtherUserNickname(userNicknames: [String], userNickname : String) -> String
    func loadMessageList(channelID: String, userID: String ) async throws -> [Message]
    func listenNewMessage(channelID: String , completion: @escaping ((Message) -> Void))
    func sendMessage(message: Message , channelID: String) async throws
    func sendImageMessage(message: Message, imageData: Data ,channelID:String) async throws
    func updateUnreadCount(channelID: String , userID: String) async throws
    func leaveChatRoom(channelID: String , userID: String) async throws
    func resetMessageData()
}

@available(iOS 15, *)
public struct ChatUsecase : ChatUsecaseProtocol {
    
    let chatRepository: ChatRepository = DefaultChatRepository()
    let messageRepository : MessageRepository = DefaultMessageRepository()
    
    let storage = StorageManager.shared
    
    public init() {}
    
    //채널 생성
    //sendMessage or sendImage을 할때 현재 생성된 채널ID가 ""이면 채널 생성
    ///
    /// - Parameters:
    ///   - channel: 새로 추가할려는 채널
    /// - Returns: 새로 생성된 채널ID
    public func createChannel(channel: Channel) async throws -> String{
        try await chatRepository.createChannel(channel: channel)
    }
    
    //채팅방 리스트탭에서 채팅방 목록 불러오기
    ///
    /// - Parameters:
    ///   - userID: 현재 내 ID
    /// - Returns: 내 ID로 생성된 채널 List
    public func loadChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void) {
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
    public func loadChannelID(tradeID: String, userID: String) async throws -> String? {
        try await chatRepository.readChannelID(tradeID: tradeID, userID: userID)
    }
    
    
    //채팅방 리스트에서 상대방 닉네임을 보여줘야 할때
    ///
    /// - Parameters:
    ///   - userNicknames: 현재 채널의 유저 닉네임들
    ///   - userNickname : 내 닉네임
    /// - Returns: 상대방 닉네임
    public func loadOtherUserNickname(userNicknames: [String], userNickname: String) -> String {
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
    public func loadOtherUserNickname(users: [String], userID: String) -> String {
        guard let index = users.firstIndex(of: userID) else {
            return "상대방을 찾을수 없습니다"
        }
        return users[(index+1) % 2]
    }
    
    //채팅방 리스트에서 채팅방을 들어갔을때 채팅방 상단에 게시글의 정보가 보여야하기 때문에 채널 ID로 Trade 정보를 얻는 메소드
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    /// - Returns: Trade
    public func loadTradeInChannel(channelID: String) async throws -> Trade? {
        try await chatRepository.readTradeInChannel(channelID: channelID)
    }
    
    //메세지를 보내는 메소드
    ///
    /// - Parameters:
    ///   - message: 보내려는 메시지(imagePath는 입력 x)
    ///   - channelID : 메시지를 보내려는 채널 ID
    public func sendMessage(message: Message, channelID: String) async throws {
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
        var newMessage = message
        let imageData = await UIImage(data: imageData)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 1)
        if let imageData {
            newMessage.imagePath = try await storage.uploadImage(path: .chat, containerID: message.id, imageData: imageData)
        }
        try await sendMessage(message: newMessage, channelID: channelID)
    }
    
    //안읽은 메시지 수 업데이트하는 메소드
    //채팅방뷰에서 onAppear,onDisappear에서 사용
    ///
    /// - Parameters:
    ///   - channelID: 현재 채팅방 채널ID
    ///   - userID: 내 ID
    public func updateUnreadCount(channelID: String, userID: String) async throws {
        try await chatRepository.updateUnreadCount(channelID: channelID, userID: userID)
    }
    
    //채팅방 나가기
    ///
    /// - Parameters:
    ///   - channelID: 현재 채팅방 채널ID
    ///   - userID: 내 ID
    public func leaveChatRoom(channelID: String, userID: String) async throws {
        try await chatRepository.updateLeftChatUser(channelID: channelID, userID: userID)
        
        if try await chatRepository.readLeftBothUser(channelID: channelID) {
            try await chatRepository.deleteChannel(channelID: channelID)
            try await messageRepository.deleteMessageList(channelId: channelID)
        }
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
        try await messageRepository.readMessageList(channelID: channelID, userID: userID)
    }
    
    //최초로 채팅방 들어가면 새롭게 추가되는 채팅들에 대한 Listner
    ///
    /// - Parameters:
    ///   - channelID: 현재 들어온 채널 ID
    /// - Returns: 새롭게 추가된 메세지
    ///
    public func listenNewMessage(channelID: String, completion: @escaping ((Message) -> Void)) {
        messageRepository.updateNewMessage(channelID: channelID) { message in
            completion(message)
        }
    }
    
    //채팅방에 나갈때(Disappear) 할때 사용해야하는 메소드
    public func resetMessageData() {
        messageRepository.resetData()
    }
}
