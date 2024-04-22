//
//  File.swift
//
//
//  Created by 정운관 on 4/6/24.
//

import Foundation

@available(iOS 15, *)
public protocol MessageRepository {
    func createMessage(message: Message , channelID: String) async throws
    func readMessageList(channelID: String, userID: String ) async throws -> [Message]
    func readMessage(channelID: String, messageID: String) async throws -> Message
    func readNewMessage(channelID: String , userID: String , completion: @escaping ((Message) -> Void))
    func updateMessageReadStatus(channelID:String , lastMessage: Message , userID: String) async throws
    func deleteMessageList(channelId: String) async throws
    func deleteListener() 
}
