//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation

public enum UserLevel: Int, Codable {
    case banned = 0
    case consumer = 1
    case admin = 2
}

public enum Location: String, Codable {
    case seoul
    case gyeonggi
    case incheon
    case gwangju
    case busan
    case dague
    case daejeon
    case ulsan
    case gangwon
    case gyeongBuk
    case gyeongNam
    case jeonBuk
    case jeonNam
    case chungBuk
    case chungNam
    case sejong
    case jeju
}

/// DB에 저장되는 유저의 정보
public struct User: Codable, Identifiable {
    /// 유저의 고유 식별값
    public var id: String
    public var nickname: String
    public var profileImage: String
    public var email: String
    
    /// 유저가 선호하는 지역
    public var favoriteLocation: Location
    
    /// 유저의 상태
    public var userLevel: UserLevel
    
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
    
    
    public init(
        id: String,
        nickname: String,
        profileImage: String = "https://firebasestorage.googleapis.com/v0/b/anbd-project3.appspot.com/o/profileImage%2F4971976.png?alt=media&token=dd1cec4c-4826-4ddd-9a83-d07aaf4259a2",
        email: String,
        favoriteLocation: Location,
        userLevel: UserLevel = .consumer,
        isOlderThanFourteen: Bool,
        isAgreeService: Bool,
        isAgreeCollectInfo: Bool,
        isAgreeMarketing: Bool, 
        likeArticles: [String] = [],
        likeTrades: [String] = []
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImage = profileImage
        self.email = email
        self.favoriteLocation = favoriteLocation
        self.userLevel = userLevel
        self.isOlderThanFourteen = isOlderThanFourteen
        self.isAgreeService = isAgreeService
        self.isAgreeCollectInfo = isAgreeCollectInfo
        self.isAgreeMarketing = isAgreeMarketing
        self.likeArticles = likeArticles
        self.likeTrades = likeTrades
    }
}
