//
//  ChatViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

//MARK: - 채널 관련 및 기본 변수들
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
    @Published var isBlocked: Bool = false

    
    @Published var selectedTrade: Trade?
    @Published var selectedChannel: Channel?
    
    @Published var groupedMessages: [(day:String , messages:[Message])] = []
    
    private var isListener: Bool = false
    private var isLeaveChatRoom: Bool = false
    
    init() {
        Task {
            fetchChatRooms()
        }
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
            #if DEBUG
            print("Error: \(error)")
            #endif
            guard let error = error as? ChannelError else {
                ToastManager.shared.toast = Toast(style: .error, message: "채팅방 생성에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
            self.selectedChannel = nil
        }
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
            #if DEBUG
            print("leaveChatRoom ERROR: \(error)")
            #endif
        }
    }
    
    /// 안읽은 메시지 개수 초기화
    func resetUnreadCount(channelID: String) async throws {
        do {
            try await chatUsecase.updateUnreadCount(channelID: channelID, userID: user.id)
        } catch {
            #if DEBUG
            print("Error: \(error)")
            #endif
        }
    }
}

//MARK: - 메시지 관련
extension ChatViewModel {
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
                setOtherUserProfileImageMessage()
            }
            
            //채팅방에 들어왔을때 한번만 실행되야 하는 것들
            if !isListener {
                await updateActiveUser(channelID: channelID, into: true)
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
                        self?.UpdateOtherUserProfileImageMessage(addMessage: message)
                    }
                    self?.updateGroupedMessagesByDate()
                }
            }
        } catch {
            #if DEBUG
            print("addListener ERROR: \(error)")
            #endif
        }
    }
    
    //메시지를 날짜별로 그룹화
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
    
    //채팅방에서 상대방 프로필 이미지를 메시지 그룹 맨 마지막에만 띄워주기위한 함수
    func setOtherUserProfileImageMessage() {
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
    
    //상대방이 메시지 보내면 그 메시지에 프로필 이미지 띄우기 위한 메소드
    func UpdateOtherUserProfileImageMessage(addMessage: Message) {
        guard addMessage.userID != user.id  else{
            return
        }
        if let lastMessage = otherUserLastMessages.last , lastMessage.dateStringWithYear == addMessage.dateStringWithYear{
            otherUserLastMessages.removeLast()
        }
        otherUserLastMessages.append(addMessage)
    }
    
    /// 메시지 보내기 (Text)
    func sendMessage(message: Message, channelID: String) async throws {
        do {
            /// 상대방 block 확인
            Task {
                self.selectedUser = try await userUsecase.getUserInfo(userID: selectedUser.id)
                if selectedUser.blockList.contains(user.id) {
                    ToastManager.shared.toast = Toast(style: .info, message: "대화 상대에게 차단되어 메시지를 보낼 수 없습니다.")
                } else {
                    try await chatUsecase.sendMessage(message: message, channelID: channelID)
                    guard let content = message.content else { return}
                    if await checkOtherUserInChatRoom(channelID: channelID) {
                        sendPushNotification(content: content)
                    }
                }
            }
        }
    }
    
    /// 메시지 보내기 (Image)
    func sendImageMessage(message: Message, imageData: Data, channelID: String) async throws {
        do {
            Task {
                self.selectedUser = try await userUsecase.getUserInfo(userID: selectedUser.id)
                if selectedUser.blockList.contains(user.id) {
                    ToastManager.shared.toast = Toast(style: .info, message: "대화 상대에게 차단되어 메시지를 보낼 수 없습니다.")
                } else {
                    try await chatUsecase.sendImageMessage(message: message, imageData: imageData, channelID: channelID)
                    if await checkOtherUserInChatRoom(channelID: channelID) {
                        sendPushNotification(content: "사진을 보냈습니다")
                    }
                }
            }
        }
    }
    
    /// 채팅방 onDisappear시, 메시지 데이터 초기화
    func resetMessageData(channelID: String) async {
        isListener = false
        isLeaveChatRoom = false
        chatUsecase.initializeListener()
        messages = []
        groupedMessages = []
        otherUserLastMessages = []
        await updateActiveUser(channelID: channelID, into: false)
    }
    
    func updateActiveUser(channelID: String , into: Bool) async{
        do {
            try await chatUsecase.updateActiveUser(channelID: channelID, userID: user.id , into: into)
        }
        catch {
            #if DEBUG
            print("updateActiveUser:\(error)")
            #endif
        }
    }
    
    //현재 채팅방에 상대방이 들어와있는지 확인
    func checkOtherUserInChatRoom(channelID: String) async -> Bool {
        do {
            let activeUser = try await chatUsecase.loadActiveUser(channelID: channelID)
            if activeUser.contains(user.id) && activeUser.count == 2 {
                return false
            }
            return true
        } catch {
            #if DEBUG
            print("checkOtherUserInChatRoom error:\(error)")
            #endif
            return false
        }
    }
}

//MARK: - 정보를 get OR Set
extension ChatViewModel {
    
    /// 채팅방 onDisappear시, 메시지 데이터 초기화
    func resetMessageData() {
        isListener = false
        isLeaveChatRoom = false
        chatUsecase.initializeListener()
        messages = []
        groupedMessages = []
    }
}

//MARK: - 정보를 get OR Set
extension ChatViewModel {
    
    //채팅방 리스트에서 접근시
    func setSelectedInfo(channel: Channel) async throws{
        self.selectedChannel = channel
        self.selectedTrade = try await chatUsecase.getTradeInChannel(channelID: channel.id)
        do {
            self.selectedUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            self.isBlocked = user.blockList.contains(selectedUser.id)
        } catch {
            self.selectedUser = User(id: "", nickname: "(알수없음)", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
        }
    }
    
    func setSelectedUser(channel: Channel) async {
        do {
            self.selectedUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            self.isBlocked = user.blockList.contains(selectedUser.id)
        } catch {
            #if DEBUG
            print("setSelectedUser: \(error)")
            #endif
            self.selectedUser = User(id: "", nickname: "(알수없음)", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
        }
    }
    
    
    
    //Trade 디테일에서 접근시
    func setSelectedInfo(trade: Trade) async throws {
        self.selectedTrade = trade
        //채널 없으면 nil
        self.selectedChannel = try await getChannel(tradeID: trade.id)
        do {
            self.selectedUser = try await userUsecase.getUserInfo(userID: trade.writerID)
            self.isBlocked = user.blockList.contains(selectedUser.id)
        } catch {
            #if DEBUG
            print("setSelectedInfo: \(error)")
            #endif
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
    
    /// 채팅방에 있는 다른 유저를 얻어오는 메소드
    func getOtherUser(channel: Channel) async -> User {
        do {
            let otherUser = try await chatUsecase.getOtherUser(channel: channel, userID: user.id)
            return otherUser
        } catch {
            return User(id: "", nickname: "알수없음", email: "", favoriteLocation: .seoul, fcmToken: "", isOlderThanFourteen: false, isAgreeService: false, isAgreeCollectInfo: false, isAgreeMarketing: false)
        }
    }
    
    /// 채팅방 유저 Block · Unblock
    func blockUnBlockUser() async {
        do {
            if isBlocked {
                try await userUsecase.unblockUser(userID: self.user.id, unblockUserID: self.selectedUser.id)
                isBlocked = false
            } else {
                try await userUsecase.blockUser(userID: self.user.id, blockUserID: self.selectedUser.id)
                isBlocked = true
                
                ToastManager.shared.toast = Toast(style: .success, message: "\(selectedUser.nickname)님을 차단했습니다.")
            }
        } catch {
            #if DEBUG
            print("Block User : \(error)")
            #endif
        }
    }
    
    // 채널리스트에서 안읽은 개수 총합을 구하는 로직
    private func getTotalUnreadCount() {
        totalUnreadCount = self.chatRooms.reduce(0) { result, channel in
            if channel.lastSendId != user.id {
                return result + channel.unreadCount
            } else {
                return result + 0
            }
        }
    }
    
    /// 채팅방 Trade 가져오기 -> 어디서 쓰고 있는지호
    private func getTrade(channelID: String) async throws -> Trade? {
        do {
            return try await chatUsecase.getTradeInChannel(channelID: channelID)
        } catch {
            #if DEBUG
            print("getTrade Error: \(error)")
            #endif
            return nil
        }
    }
    
    /// 채널 가져오기
    func getChannel(tradeID: String) async throws -> Channel? {
        do {
            return try await chatUsecase.getChannel(tradeID: tradeID, userID: user.id)
        } catch {
            #if DEBUG
            print("getChannel: \(error)")
            #endif
            return nil
        }
    }
    
    /// 채널 가져오기
    func getChannel(channelID: String) async throws -> Channel? {
        do {
            return try await chatUsecase.getChannel(channelID: channelID)
        } catch {
            #if DEBUG
            print("getChannel(channelId:): \(error)")
            #endif
            guard let error = error as? ChannelError else {
                ToastManager.shared.toast = Toast(style: .error, message: "채팅방 정보 가져오기에 실패하였습니다.")
                return nil
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
            
            return nil
        }
    }
}


//MARK: - 이미지
extension ChatViewModel {
    /// 이미지 다운로드 - chatHeaderView 썸네일
    func loadThumnailImage(containerID: String, imagePath: String) async throws -> Data {
        do {
            return try await storageManager.downloadImage(path: .trade, containerID: "\(containerID)/thumbnail", imagePath: imagePath)
        } catch {
            #if DEBUG
            print("HomeViewModel Error loadImage : \(error) \(error.localizedDescription)")
            #endif
            /// 이미지 예외 처리
            let image = UIImage(named: "ANBDWarning")
            let imageData = image?.pngData()

            return imageData ?? Data()
        }
    }
    
    /// 메시지 사진 로드 -> 얘도 안쓰는 듯!!!
    func downloadImagePath(messageID: String, imagePath: String) async throws -> Data {
        do {
            return try await chatUsecase.downloadImage(messageID: messageID, imagePath: imagePath)
        } catch {
            #if DEBUG
            print("downloadImagePath Error: \(error)")
            #endif
            /// 이미지 예외 처리
            let image = UIImage(named: "ANBDWarning")
            let imageData = image?.pngData()

            return imageData ?? Data()
        }
    }
    
    /// 메시지 사진 로드
    func downloadImageUrl(messageID: String, imagePath: String) async throws -> URL? {
        do {
            return try await storageManager.downloadImageToUrl(path: .chat, containerID: messageID, imagePath: imagePath)
        } catch {
            #if DEBUG
            print("downloadImageUrl Error: \(error)")
            #endif
            return nil
        }
    }
}

//MARK: - chatHeaderView
extension ChatViewModel {
    /// 거래 상품 상태 변경
    func updateTradeState(tradeID: String, tradeState: TradeState) async {
        do {
            self.selectedTrade?.tradeState = tradeState
            try await tradeUsecase.updateTradeState(tradeID: tradeID, tradeState: tradeState)
        } catch {
            #if DEBUG
            print("updateTradeState Error: \(error.localizedDescription)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래 상태 변경에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func loadTrade(tradeID: String) async {
        do {
            self.selectedTrade = try await tradeUsecase.loadTrade(tradeID: tradeID)
        } catch {
            #if DEBUG
            print("loadTrade \(error.localizedDescription)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 불러오기에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
}

//MARK: - 푸시알람
extension ChatViewModel {
    func sendPushNotification(content: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        
        guard let serverKey = Bundle.main.firebaseServerKey else {return}
        
        guard selectedUser.fcmToken != "" else {return}
        
        guard let channel = self.selectedChannel else {return}
        
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
            ],
            "content_available" : true,
            "data": [
                "channelID": channel.id
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
