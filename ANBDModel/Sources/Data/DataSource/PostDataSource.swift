//
//  PostDataSource.swift
//
//
//  Created by 유지호 on 4/15/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
protocol Postable<Item>: AnyObject {
    associatedtype Item: Codable & Identifiable
    
    var database: CollectionReference { get }
    
    var allQuery: Query? { get set }
    var writerIDQuery: Query? { get set }
    var searchQuery: Query? { get set }
    var orderQuery: Query? { get set }
    var filterQuery: Query? { get set }
    
    func createItem(item: Item) async throws
    func readItem(itemID: String) async throws -> Item
    func readItemList(limit: Int) async throws -> [Item]
    func readItemList(writerID: String, limit: Int) async throws -> [Item]
    func refreshAll(limit: Int) async throws -> [Item]
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Item]
    func deleteItem(itemID: String) async throws
    func resetSearchQuery()
}


@available(iOS 15, *)
class PostDataSource<T: Codable & Identifiable>: Postable {
    
    typealias Item = T
    
    let database: CollectionReference
    
    var allQuery: Query?
    var writerIDQuery: Query?
    var searchQuery: Query?
    var orderQuery: Query?
    var filterQuery: Query?
    
    init(database: CollectionReference) {
        self.database = database
        
        #if DEBUG
        print("\(T.self) DataSource init")
        #endif
    }
    
    deinit {
        #if DEBUG
        print("\(T.self) DataSource deinit")
        #endif
    }
    
    
    func createItem(item: T) async throws {
        guard let _ = try? database.document("\(item.id)").setData(from: item)
        else {
            throw DBError.setDocumentError
        }
    }
    
    func readItem(itemID: String) async throws -> T {
        guard let item = try? await database
            .document(itemID)
            .getDocument()
            .data(as: T.self)
        else {
            throw DBError.getDocumentError
        }
        
        return item
    }
    
    func readItemList(limit: Int) async throws -> [T] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = database
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = database
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError
        }
        
        let itemList = snapshot.compactMap { try? $0.data(as: T.self) }
        return itemList
    }
    
    func readItemList(writerID: String, limit: Int) async throws -> [T] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = database
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = database
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.writerIDQuery = next
        }
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError
        }
        
        let itemList = snapshot.compactMap { try? $0.data(as: T.self) }
        return itemList
    }
    
    func refreshAll(limit: Int) async throws -> [T] {
        allQuery = nil
        return try await readItemList(limit: limit)
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [T] {
        writerIDQuery = nil
        return try await readItemList(writerID: writerID, limit: limit)
    }
    
//    func updateItem(item: T) async throws { }
    
    func deleteItem(itemID: String) async throws {
        guard let _ = try? await database.document(itemID).delete()
        else {
            throw DBError.deleteDocumentError
        }
    }
    
    func resetSearchQuery() {
        searchQuery = nil
    }
    
}
