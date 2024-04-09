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

final class DefaultMessageRepository: MessageRepository {
    
    private var chatDB = Firestore.firestore().collection("ChatRoom")
    
    private var startDoc: DocumentSnapshot?
    private var lastDoc: DocumentSnapshot?
    private var endPaging: Bool = false
    private var listener: ListenerRegistration?
    
    func createMessage(message: Message, channelID: String) async throws {
        guard let _ = try? chatDB.document(channelID).collection("messages").document(message.id).setData(from: message) else {
            throw DBError.setDocumentError(message: "message 컬렉션에 데이터를 업데이트하는데 실패하였습니다.")
        }
    }
    
    func readMessageList(channelID: String , userID: String) async throws -> [Message] {
        
        if endPaging {return []}
        let commonQuery = chatDB
            .document(channelID)
            .collection("messages")
            .order(by: "createdAt")
            .limit(toLast: 20)
        
        let requestQuery : Query
        
        if let startDoc = startDoc {
            requestQuery = commonQuery.end(beforeDocument: startDoc)
        } else {
            requestQuery = commonQuery
        }
        
        guard let snapshot = try? await requestQuery.getDocuments() else {
            throw DBError.getDocumentError(message: "channelID에 해당하는 messages Document를 얻어오는데 실패했습니다")
        }
        
        if snapshot.documents.isEmpty {
            endPaging = true
            return []
        }
        
        startDoc = snapshot.documents.first
        lastDoc = snapshot.documents.last
        
        return snapshot.documents.compactMap {try? $0.data(as: Message.self)}.filter{!$0.leaveUsers.contains(userID)}
    }
    
    func updateNewMessage(channelID: String, completion: @escaping ((Message) -> Void)) {
        
        let commonQuery = chatDB
            .document(channelID)
            .collection("messages")
            .order(by: "createdAt")
        
        let requestQuery: Query
        
        if let lastDoc = lastDoc {
            requestQuery = commonQuery
                .start(afterDocument: lastDoc)
        } else {
            requestQuery = commonQuery
        }
        
       listener = requestQuery
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("메시지 업데이트 에러 : \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        guard let newMessage = try? diff.document.data(as: Message.self) else {
                            print("message 변환 오류")
                            return
                        }
                        completion(newMessage)
                    }
                    if (diff.type == .modified) {print("modified:\(diff.document.data())")}
                    if (diff.type == .removed) {print("removed:\(diff.document.data())")}
                }
            }
    }
    
    func resetData() {
        startDoc = nil
        lastDoc = nil
        endPaging = false
        listener?.remove()
    }
    
    func deleteMessageList(channelId: String) async throws {
        let querySnapshot = try await chatDB.document(channelId).collection("messages").getDocuments()
        for document in querySnapshot.documents {
            guard let _ = try? await chatDB.document(channelId).collection("messages").document(document.documentID).delete() else {
                throw DBError.deleteDocumentError(message: "channelID가 일치하는 messages Documents를 삭제하는데 실패했습니다.")
            }
        }
    }
}
