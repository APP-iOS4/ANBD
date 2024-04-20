//
//  FirestoreDatabase.swift
//
//
//  Created by 유지호 on 4/20/24.
//

import Foundation
import FirebaseFirestore

extension CollectionReference {
    
    static var userDatabase: CollectionReference {
        return Firestore.firestore().collection("User")
    }
    
    static var articleDatabase: CollectionReference {
        return Firestore.firestore().collection("ArticleBoard")
    }
    
    static var commentDatabase: CollectionReference {
        return Firestore.firestore().collection("CommentBoard")
    }
    
    static var tradeDatabase: CollectionReference {
        return Firestore.firestore().collection("TradeBoard")
    }
    
    static var chatroomDatabase: CollectionReference {
        return Firestore.firestore().collection("ChatRoom")
    }
    
    static var bannerDatabase: CollectionReference {
        return Firestore.firestore().collection("Banner")
    }
    
}
