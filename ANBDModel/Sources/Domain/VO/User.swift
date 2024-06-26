//
//  User.swift
//
//
//  Created by 유지호 on 4/3/24.
//

import Foundation

/// DB에 저장되는 유저의 정보
@available(iOS 15, *)
public struct User: Codable, Identifiable, Hashable {
    /// 유저의 고유 식별값
    public let id: String

    public var nickname: String
    public var profileImage: String
    public var email: String
    
    /// 유저가 선호하는 지역
    public var favoriteLocation: Location
    
    /// 유저의 상태
    public var userLevel: UserLevel
    
    public var fcmToken: String
    
    /// 만 14세 이상
    public var isOlderThanFourteen: Bool
    
    /// 서비스 이용약관 동의
    public var isAgreeService: Bool
    
    /// 개인정보 수집 동의
    public var isAgreeCollectInfo: Bool
    
    /// 광고 및 마케팅 수신 동의
    public var isAgreeMarketing: Bool
    
    /// 좋아요한 아껴쓰기, 다시쓰기 목록
    public var likeArticles: [String]
    
    /// 찜한 나눠쓰기, 바꿔쓰기 목록
    public var likeTrades: [String]
    
    /// 작성한 아껴쓰기 글 갯수
    public var accuaCount: Int
    
    /// 작성한 나눠쓰기 글 갯수
    public var nanuaCount: Int
    
    /// 작성한 바꿔쓰기 글 갯수
    public var baccuaCount: Int
    
    /// 작성한 다시쓰기 글 갯수
    public var dasiCount: Int
    
    public var blockList: [String]
    
    
    public init(
        id: String,
        nickname: String,
        profileImage: String = "https://firebasestorage.googleapis.com/v0/b/anbd-project3.appspot.com/o/Profile%2FDefaultUserProfileImage.png?alt=media&token=fc0e56d9-6855-4ead-ab28-d8ff789799b3",
        email: String,
        favoriteLocation: Location,
        userLevel: UserLevel = .consumer,
        fcmToken: String,
        isOlderThanFourteen: Bool,
        isAgreeService: Bool,
        isAgreeCollectInfo: Bool,
        isAgreeMarketing: Bool, 
        likeArticles: [String] = [],
        likeTrades: [String] = [],
        accuaCount: Int = 0,
        nanuaCount: Int = 0,
        baccuaCount: Int = 0,
        dasiCount: Int = 0,
        blockList: [String] = []
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImage = profileImage
        self.email = email
        self.favoriteLocation = favoriteLocation
        self.userLevel = userLevel
        self.fcmToken = fcmToken
        self.isOlderThanFourteen = isOlderThanFourteen
        self.isAgreeService = isAgreeService
        self.isAgreeCollectInfo = isAgreeCollectInfo
        self.isAgreeMarketing = isAgreeMarketing
        self.likeArticles = likeArticles
        self.likeTrades = likeTrades
        self.accuaCount = accuaCount
        self.nanuaCount = nanuaCount
        self.baccuaCount = baccuaCount
        self.dasiCount = dasiCount
        self.blockList = blockList
    }
}
