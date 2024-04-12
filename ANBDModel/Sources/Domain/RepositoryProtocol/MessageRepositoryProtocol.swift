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
    func updateNewMessage(channelID: String , completion: @escaping ((Message) -> Void))
    func deleteMessageList(channelId: String) async throws
    func resetData() 
}
