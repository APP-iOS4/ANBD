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
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    private let tradeUsecase: TradeUsecase = DefaultTradeUsecase()
    private let storageManager = StorageManager.shared
    
    @Published var user: User = UserStore.shared.user
    @Published var chatRooms: [Channel] = []
    @Published var messages: [Message] = []
    @Published var otherUserLastMessages: [Message] = []
    @Published var otherUserProfileImageUrl: String = ""
    @Published var totalUnreadCount: Int = 0
    
    //채팅방 내부에 필요한 변수
    var selectedUser: User = User(id: "", nickname: "(알수없음)", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
    
    var selectedTrade: Trade?
    var selectedChannel: Channel?
    
    @Published var groupedMessages: [(day:String , messages:[Message])] = []
    
    private var isListener: Bool = false
    private var isLeaveChatRoom: Bool = false
    
    init() {
        Task {
            fetchChatRooms()
        }
    }
    
    /// fetch + listener
    func addListener(channelID: String) async throws {
        do {
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
        Task {
            guard let userID = UserDefaultsClient.shared.userID else { return }
            user = await UserStore.shared.getUserInfo(userID: userID)
            chatUsecase.loadChannelList(userID: user.id) { [weak self] channel in
                self?.chatRooms = channel
                self?.getTotalUnreadCount()
            }
        }
    }
    
    
    /// 채널 생성 (처음 채팅을 남길 때) : ChannelID 반환
    func makeChannel(channel: Channel) async throws {
        do {
            self.selectedChannel = try await chatUsecase.createChannel(channel: channel)
        } catch {
            print("Error: \(error)")
            self.selectedChannel = nil
        }
    }
    
    
    /// 채널 가져오기
    private func getChannel(tradeID: String) async throws -> Channel? {
        do {
            return try await chatUsecase.getChannel(tradeID: tradeID, userID: user.id)
        } catch {
            return nil
        }
    }
    
    //채팅방 리스트에서 접근시
    func setSelectedUser(channel: Channel) async throws{
        self.selectedChannel = channel
        
        do {
            self.selectedUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            self.selectedTrade = try await chatUsecase.getTradeInChannel(channelID: channel.id)
        } catch DBError.getTradeDocumentError {
            self.selectedTrade = nil
        }
        catch {
            self.selectedUser = User(id: "", nickname: "(알수없음)", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
        }
    }
    
    //Trade 디테일에서 접근시
    func setSelectedUser(trade: Trade) async throws {
        self.selectedUser = try await userUsecase.getUserInfo(userID: trade.writerID)
        self.selectedTrade = trade
        self.selectedChannel = try await getChannel(tradeID: trade.id)
    }
    
    func getOtherUser(channel: Channel) async -> User {
        do {
            let otherUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            return otherUser
        } catch {
            print("getOtherUser error: \(error)")
            return User(id: "", nickname: "알수없음", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
        }
    }
    
    func updateLastMessage() {
        var otherMessages: [Message] = []
        
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
        guard addMessage.userID != user.id  else{
            return
        }
        if let lastMessage = otherUserLastMessages.last , lastMessage.dateStringWithYear == addMessage.dateStringWithYear{
            otherUserLastMessages.removeLast()
        }
        otherUserLastMessages.append(addMessage)
    }
    
    func getTotalUnreadCount() {
        totalUnreadCount = self.chatRooms.reduce(0) { result, channel in
            if channel.lastSendId != user.id {
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
            print("getTrade Error: \(error)")
            return nil
        }
    }
    
    
    /// 거래 상품 상태 변경
    func updateTradeState(tradeID: String, tradeState: TradeState) async {
        do {
            self.selectedTrade?.tradeState = tradeState
            try await tradeUsecase.updateTradeState(tradeID: tradeID, tradeState: tradeState)
        } catch {
            print("updateTradeState Error: \(error.localizedDescription)")
        }
    }
    
    func loadTrade(tradeID: String) async {
        do {
            self.selectedTrade = try await tradeUsecase.loadTrade(tradeID: tradeID)
        } catch {
            print("loadTrade \(error.localizedDescription)")
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
            print("downloadImagePath Error: \(error)")
            return Data()
        }
    }
    
    /// 메시지 사진 로드
    func downloadImageUrl(messageID: String, imagePath: String) async throws -> URL? {
        do {
            return try await storageManager.downloadImageToUrl(path: .chat, containerID: messageID, imagePath: imagePath)
        } catch {
            print("downloadImageUrl Error: \(error)")
            return nil
        }
    }
    
    /// 메시지 보내기 (Text)
    func sendMessage(message: Message, channelID: String) async throws {
        do {
            try await chatUsecase.sendMessage(message: message, channelID: channelID)
            guard let content = message.content else { return}
            sendPushNotification(content: content)
        } catch {
            print("sendMessage Error: \(error)")
        }
    }
    
    /// 메시지 보내기 (Image)
    func sendImageMessage(message: Message, imageData: Data, channelID: String) async throws {
        do {
            try await chatUsecase.sendImageMessage(message: message, imageData: imageData, channelID: channelID)
            sendPushNotification(content: "사진을 보냈습니다")
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
            try await chatUsecase.leaveChatRoom(channelID: channelID, lastMessageID: lastMessageID, userID: user.id)
        } catch {
            print("leaveChatRoom ERROR: \(error)")
        }
    }
    
    /// 안읽은 메시지 개수 초기화
    func resetUnreadCount(channelID: String) async throws {
        do {
            try await chatUsecase.updateUnreadCount(channelID: channelID, userID: user.id)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    /// 채팅방 쌓인 메시지 개수 불러오기
    func getUnreadCount(channel: Channel) -> Int {
        var cnt = 0
        if channel.lastSendId != user.id {
            cnt = channel.unreadCount
        }
        return cnt
    }
    
    func sendPushNotification(content: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        
        
        guard let serverKey = Bundle.main.firebaseServerKey else {return}
        
        guard selectedUser.fcmToken != "" else {return}
        
        print("serverKey:\(serverKey)")
        print("to:\(selectedUser.fcmToken)")
        
        let headers = [
            "Authorization": "key=\(serverKey)",
            "Content-Type": "application/json"
        ]
        let body: [String: Any] = [
            "to": selectedUser.fcmToken,
            "notification": [
                "title": "\(user.nickname)",
                "body": content
            ]
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error.localizedDescription)")
            }
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString ?? "")")
            }
        }.resume()
    }
}


