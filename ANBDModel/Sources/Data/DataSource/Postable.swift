//
//  Postable.swift
//
//
//  Created by 유지호 on 4/15/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
protocol Postable {
    associatedtype Item: Codable & Identifiable & Hashable
    
    func createItem(item: Item) async throws
    func readItem(itemID: String) async throws -> Item
    func readItemList(limit: Int) async throws -> [Item]
    func readItemList(writerID: String, limit: Int) async throws -> [Item]
    func readItemList(keyword: String, limit: Int) async throws -> [Item]
    func refreshAll(limit: Int) async throws -> [Item]
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Item]
    func refreshSearch(keyword: String, limit: Int) async throws -> [Item]
    func updateItem(item: Item) async throws
    func deleteItem(itemID: String) async throws
    func resetSearchQuery()
}
