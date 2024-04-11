//
//  MypageViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

final class MyPageViewModel: ObservableObject {
    static let mockUser = User(id: "abcd1234",
                               nickname: "김마루",
                               profileImage: "DefaultUserProfileImage",
                               email: "sjybext@naver.com",
                               favoriteLocation: .jeju,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published var userProfileImage: UIImage = UIImage(named: "DefaultUserProfileImage.001.png")!
    
    @Published var user = User(id: "abcd1234",
                               nickname: "김마루",
                               profileImage: "DefaultUserProfileImage",
                               email: "sjybext@naver.com",
                               favoriteLocation: .jeju,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published private(set) var userArticles: [Article] = []
    @Published private(set) var userTrades: [Trade] = []
    
    let mockArticleData: [Article] = [
        .init(writerID: "writerID", writerNickname: "닉네임닉네임닉네임닉네임닉네임닉네임닉네임", category: .accua, title: "아껴제목1", content: "내용내용5", likeCount: 30, commentCount: 50),
        .init(writerID: "writerID", writerNickname: "닉네임", category: .accua, title: "아껴제목2", content: "내용내용4", likeCount: 50, commentCount: 40),
        .init(writerID: "writerID", writerNickname: "김기표", category: .accua, title: "아껴제목3", content: "내용내용3", likeCount: 10, commentCount: 30),
        .init(writerID: "writerID", writerNickname: "닉네임4", category: .accua, title: "아껴제목4", content: "내용내용2", likeCount: 40, commentCount: 20),
        .init(writerID: "writerID", writerNickname: "닉네임5", category: .accua, title: "아껴제목5", content: "내용내용1", likeCount: 20, commentCount: 10),
        .init(writerID: "writerID", writerNickname: "닉네임1", category: .dasi, title: "다시제목1", content: "내용내용5", likeCount: 10, commentCount: 50),
        .init(writerID: "writerID", writerNickname: "닉네임2", category: .dasi, title: "다시제목2", content: "내용내용4", likeCount: 20, commentCount: 40),
        .init(writerID: "writerID", writerNickname: "닉네임3", category: .dasi, title: "다시제목3", content: "내용내용3", likeCount: 30, commentCount: 30),
        .init(writerID: "writerID", writerNickname: "닉네임4", category: .dasi, title: "다시제목4", content: "내용내용2", likeCount: 40, commentCount: 20),
        .init(writerID: "writerID", writerNickname: "닉네임5", category: .dasi, title: "다시제목5", content: "내용내용1", likeCount: 50, commentCount: 10),
    ]
    
    let mockTradeData: [Trade] = [
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .beautyCosmetics, location: .busan, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyImage1"]),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .sportsLeisure, location: .jeju, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy1"]),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy2"]),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy3"]),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
            .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: [])
    ]
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    func validateEditingComplete() -> Bool {
        if (editedUserNickname.isEmpty || editedUserNickname == self.user.nickname) && (tempUserFavoriteLocation != self.user.favoriteLocation) {
            return true
        } else {
            return false
        }
    }
}
