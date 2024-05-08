//
//  File.swift
//
//
//  Created by 정운관 on 4/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15, *)
final class DefaultChatRepository: ChatRepository {

    private var db = Firestore.firestore()
    private let chatDB = Firestore.firestore().collection("ChatRoom")
    
    private var listener : ListenerRegistration?
    
    func createChannel(channel: Channel) async throws -> Channel {
        guard let _ = try? chatDB.document(channel.id).setData(from: channel)
        else {
            throw DBError.setChannelDocumentError
        }
        return channel
    }
    
    func readChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void){
        listener = chatDB
            .whereField("users", arrayContains: userID)
            .order(by: "lastSendDate", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let document = snapshot else {
                    print("채널리스트 업데이트 에러 : \(error!)")
                    return
                }
                let channels =  document.documents.compactMap { try? $0.data(as: Channel.self) }.filter{!$0.leaveUsers.contains(userID)}
                completion(channels)
        }
    }
    
    func deleteListener() {
        listener?.remove()
    }
    
    private func sortedChannel(channels : [Channel]) -> [Channel] {
        return channels.sorted(by: {
            if $0.lastSendDate != $1.lastSendDate {
                if $0.unreadCount > 0 && $1.unreadCount > 0 {
                    return $0.lastSendDate > $1.lastSendDate
                }
                else if $0.unreadCount == 0 && $1.unreadCount == 0 {
                    return $0.lastSendDate > $1.lastSendDate
                }
                else {
                    return $0.unreadCount > $01.unreadCount
                }
            }
            return true
        })
    }
    
    func readChannel(tradeID: String, userID: String) async throws -> Channel? {
        guard let querySnapshot = try? await chatDB
            .whereField("users", arrayContains: userID)
            .whereField("tradeId", isEqualTo: tradeID)
            .getDocuments()
        else {
            throw DBError.getChannelDocumentError
        }
        
        guard let document = querySnapshot.documents.first else {
            return nil
        }
        
        let channel = try? document.data(as: Channel.self)
        return channel
    }
    
    func readChannel(channelID: String) async throws -> Channel? {
        guard let querySnapshot = try? await chatDB
            .whereField("id", isEqualTo: channelID)
            .getDocuments()
        else {
            throw DBError.getChannelDocumentError
        }
        
        guard let document = querySnapshot.documents.first else {
            return nil
        }
        
        let channel = try? document.data(as: Channel.self)
        return channel
    }
    
    func readTradeInChannel(channelID: String) async throws -> Trade? {
        guard let documnet = try? await chatDB.document(channelID).getDocument() else {
            throw DBError.getChannelDocumentError
        }
        guard let data = documnet.data(), let tradeID = data["tradeId"] as? String else {
            throw DBError.getChannelDocumentError        }
        
        guard let trade = try? await db.collection("TradeBoard").document(tradeID).getDocument(as : Trade.self) else {
            return nil
        }
        
        return trade
        
    }
    
    func readLeftBothUser(channelID: String) async throws -> Bool {
        let document = try await chatDB.document(channelID).getDocument()
        guard let data = document.data(), let leaveUsers = data["leaveUsers"] as? [String], let users = data["users"] as? [String] , Set(leaveUsers) == Set(users) else {
            return false
        }
        return true
    }
    
    func readActiveUsers(channelID: String) async throws -> [String] {
        let document = try await chatDB.document(channelID).getDocument()
        guard let data = document.data(), let activeUsers = data["activeUsers"] as? [String] else {
            throw DBError.getChannelDocumentError
        }
        return activeUsers
    }
    
    func updateChannel(message: Message, channelID: String) async throws {
        var lastMessage : String
        
        //만약 사진일 경우
        if let content = message.content {
            lastMessage = content
        } else {
            lastMessage = "사진을 보냈습니다"
        }
        guard let _ = try? await chatDB.document(channelID).updateData(
            [
                "lastMessage" : lastMessage ,
                "lastSendId" : message.userID,
                "lastSendDate" : message.createdAt,
                "unreadCount" : FieldValue.increment(Int64(1)),
                "leaveUsers": []
            ]
        ) else {
            throw DBError.updateChannelDocumentError
        }
    }
    
    func updateUnreadCount(channelID: String, userID: String) async throws {
        guard channelID != "" else {return}
        
        guard let document = try? await chatDB.document(channelID).getDocument() else {
            throw DBError.getChannelDocumentError
        }
        
        guard document.exists , let data = document.data() , userID != data["lastSendId"] as? String else {
            return
        }
        
        guard let _ = try? await chatDB.document(channelID).updateData(["unreadCount" : 0]) else {
            throw DBError.updateChannelDocumentError
        }
    }
    
    //현재 채팅방에 유저가 실시간으로 보고있음을 업데이트
    func updateActiveUser(channelID: String,userID: String) async throws {
        
        guard channelID != "" else {return}
        
        guard let _ = try? await chatDB.document(channelID).updateData([
            "activeUsers": FieldValue.arrayUnion([userID])
        ]) else {
            throw DBError.updateChannelDocumentError        }
    }
    
    //
    func updateLeftChatUser(channelID: String, lastMessageID: String, userID: String) async throws {
        guard let _ = try? await chatDB.document(channelID).updateData([
            "leaveUsers": FieldValue.arrayUnion([userID])
        ]) else {
            throw DBError.updateChannelDocumentError        }
        
        guard let _ = try? await chatDB.document(channelID).collection("messages").document(lastMessageID).updateData(["leaveUsers": FieldValue.arrayUnion([userID])]) else {
            throw DBError.updateMessageDocumentError
        }
    }
    
    //현재 채팅방에 유저가 실시간으로 안보고 있음을 업데이트
    func deleteActiveUser(channelID: String, userID: String) async throws {
        guard channelID != "" else {return}
        
        guard let _ = try? await chatDB.document(channelID).updateData([
            "activeUsers": FieldValue.arrayRemove([userID])
        ]) else {
            throw DBError.updateChannelDocumentError        }
    }
    
    func deleteChannel(channelID : String) async throws {
        guard let _ = try? await chatDB.document(channelID).delete() else {
            throw DBError.deleteChannelDocumentError
        }
    }
    
    
}
