//
//  File.swift
//
//
//  Created by 정운관 on 4/5/24.
//

import Foundation

@available(iOS 15, *)
public protocol ChatRepository {
    func createChannel(channel : Channel) async throws -> Channel
    func readChannelList(userID: String, completion : @escaping (_ channels: [Channel]) -> Void)
    func readChannel(tradeID : String , userID: String) async throws -> Channel?
    func readTradeInChannel(channelID: String)  async throws -> Trade?
    func readLeftBothUser(channelID: String) async throws -> Bool
    func updateChannel(message: Message , channelID: String) async throws
    func updateUnreadCount(channelID: String , userID: String) async throws
    func updateLeftChatUser(channelID: String, userID: String) async throws
    func deleteChannel(channelID : String) async  throws
    func deleteListener()
}
