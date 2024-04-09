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
struct DefaultChatRepository: ChatRepository {

    private var db = Firestore.firestore()
    let chatDB = Firestore.firestore().collection("ChatRoom")
    
    func createChannel(channel: Channel) async throws -> String {
        
        guard let _ = try? chatDB.document(channel.id).setData(from: channel)
        else {
            throw DBError.setDocumentError(message: "ChatRoom document를 추가하는데 실패했습니다.")
        }
        return channel.id
    }
    
    func readChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void){
        
        chatDB
            .whereField("users", arrayContains: userID)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else {
                    print("채널리스트 업데이트 에러 : \(error!)")
                    return
                }
                var channels =  document.documents.compactMap { try? $0.data(as: Channel.self) }.filter{!$0.leaveUsers.contains(userID)}
                channels = sortedChannel(channels: channels)
                completion(channels)
        }
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
    
    func readChannelID(tradeID: String, userID: String) async throws -> String? {
        
        guard let querySnapshot = try? await chatDB
            .whereField("users", arrayContains: userID)
            .whereField("tradeId", isEqualTo: tradeID)
            .getDocuments()
        else {
            throw DBError.getDocumentError(message: "userID에 해당하는 ChatRoom documents를 읽어오는데 실패했습니다.")
        }
        for document in querySnapshot.documents {
            let data = document.data()
            guard let channelID = data["id"] as? String else {
                return nil
            }
            return channelID
        }
        return nil
    }
    
    func readTradeInChannel(channelID: String) async throws -> Trade? {
        
        guard let documnet = try? await chatDB.document(channelID).getDocument() else {
            throw DBError.getDocumentError(message: "channelID에 해당하는 ChatRoom documents를 읽어오는데 실패했습니다.")
        }
        guard let data = documnet.data(), let tradeID = data["tradeId"] as? String else {
            throw DBError.getDocumentError(message: "채널안에 있는 TradeId 데이터를 읽는데 실패")
        }
        
        guard let trade = try? await db.collection("TradeBoard").document(tradeID).getDocument(as : Trade.self) else {
            throw DBError.getDocumentError(message: "tradeId에 해당하는 documents를 읽어오는데 실패했습니다.")
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
            throw DBError.updateDocumentError(message: "channelID에 해당하는 channel 문서를 업데이트하는데 실패했습니다.")
        }
    }
    
    func updateUnreadCount(channelID: String, userID: String) async throws {
        guard channelID != "" else {return}
        
        guard let document = try? await chatDB.document(channelID).getDocument() else {
            throw DBError.getDocumentError(message: "channelID에 해당하는 ChatRoom documents를 읽어오는데 실패했습니다.")
        }
        
        guard document.exists , let data = document.data() , userID != data["lastSendId"] as? String else {
            return
        }
        
        guard let _ = try? await chatDB.document(channelID).updateData(["unreadCount" : 0]) else {
            throw DBError.updateDocumentError(message: "channel unreadCount 필드를 업데이트하는데 실패했습니다.")
        }
        
    }
    
    func updateLeftChatUser(channelID: String, userID: String) async throws {
        
        guard let _ = try? await chatDB.document(channelID).updateData([
            "leaveUsers": FieldValue.arrayUnion([userID])
        ]) else {
            throw DBError.updateDocumentError(message: "channel leaveUsers 필드를 업데이트하는데 실패했습니다.")
        }
        
        guard let querySnapshot = try? await chatDB.document(channelID).collection("messages").getDocuments() else {
            throw DBError.getDocumentError(message: "channelID에 해당하는 messages Document 불러오기 실패했습니다")
        }
        
        for document in querySnapshot.documents {
            try await chatDB.document(channelID).collection("messages").document(document.documentID).updateData([
                "leaveUsers": FieldValue.arrayUnion([userID])
            ])
        }
    }
    
    
    func deleteChannel(channelID : String) async throws {
        guard let _ = try? await chatDB.document(channelID).delete() else {
            throw DBError.deleteDocumentError(message: "ID가 일치하는 channel document를 삭제하는데 실패했습니다.")
        }
    }
    
    
}
