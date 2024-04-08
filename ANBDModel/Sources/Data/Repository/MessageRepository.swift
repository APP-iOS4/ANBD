//
//  File.swift
//
//
//  Created by 정운관 on 4/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

@available(iOS 15, *)

struct DefaultMessageRepository: MessageRepository {
    
    
    private var chatDB = Firestore.firestore().collection("ChatRoom")
    func createMessage(message: Message, channelID: String) async throws {
        guard let _ = try? chatDB.document(channelID).collection("messages").document(message.id).setData(from: message) else {
            throw DBError.setDocumentError(message: "message 컬렉션에 데이터를 업데이트하는데 실패하였습니다.")
        }
    }
    func readMessageList(channelID: String , userID: String) async throws -> [Message] {
        guard let snapshot = try? await chatDB.document(channelID).collection("messages").getDocuments().documents else {
            throw DBError.getDocumentError(message: "channelID에 해당하는 messages Document를 얻어오는데 실패했습니다")
        }
        return snapshot.compactMap {try? $0.data(as: Message.self)}.filter{!$0.leaveUsers.contains(userID)}.sorted(by: { $0.createdAt < $1.createdAt })
    }
}
