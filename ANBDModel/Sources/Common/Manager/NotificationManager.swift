//
//  NotificationManager.swift
//
//
//  Created by 유지호 on 5/2/24.
//

import Foundation

@available(iOS 15, *)
struct NotificationManager {
    static let shared = NotificationManager()
    
    private let requestURLString = "https://fcm.googleapis.com/fcm/send"
    private let serverKey = ""
    
    private init() { }
    
    
    func sendArticleNotification(
        from sender: User, 
        to fcmToken: String,
        article: Article
    ) async {
        guard let url = URL(string: requestURLString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "key=\(serverKey)"
        ]
        
        let body: [String: Any] = [
            "to": fcmToken,
            "notification": [
                "title": article.title,
                "body": "\(sender.nickname)님이 회원님의 게시글을 좋아합니다."
            ],
            "data": [
                "type": "article",
                "articleID": article.id
            ]
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body)
        else {
            print("body serialization fail")
            return
        }
        
        request.httpBody = bodyData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            print(response)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendCommentNotification(
        from sender: User,
        to fcmToken: String,
        article: Article,
        comment: Comment
    ) async {
        guard let url = URL(string: requestURLString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "key=\(serverKey)"
        ]
        
        let body: [String: Any] = [
            "to": fcmToken,
            "notification": [
                "title": article.title,
                "body": "\(sender.nickname)님이 댓글을 남겼습니다: \(comment.content)"
            ],
            "data": [
                "type": "comment",
                "articleID": "\(article.id)"
            ]
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body)
        else {
            print("body serialization fail")
            return
        }
        
        request.httpBody = bodyData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            print(response)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
