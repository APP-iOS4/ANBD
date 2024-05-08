//
//  MyPageViewModel.swift
//  ANBDAdmin
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import Combine
import ANBDModel

@MainActor
final class MyPageViewModel: ObservableObject {
    static let mockUser = User(id: "abcd1234",
                               nickname: "알수 없음",
                               profileImage: "DefaultUserProfileImage",
                               email: "anbd@anbd.com",
                               favoriteLocation: .seoul,
                               userLevel: .consumer,
                               fcmToken: "",
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [],
                               accuaCount: 0,
                               nanuaCount: 0,
                               baccuaCount: 0,
                               dasiCount: 0)
    
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    private let articleUsecase: ArticleUsecase = DefaultArticleUsecase()
    private let tradeUsecase: TradeUsecase = DefaultTradeUsecase()
    
    @Published var user = User(id: "",
                               nickname: "",
                               profileImage: "",
                               email: "",
                               favoriteLocation: .seoul,
                               userLevel: .consumer,
                               fcmToken: "",
                               isOlderThanFourteen: false,
                               isAgreeService: false,
                               isAgreeCollectInfo: false,
                               isAgreeMarketing: false,
                               likeArticles: [],
                               likeTrades: [],
                               accuaCount: 0,
                               nanuaCount: 0,
                               baccuaCount: 0,
                               dasiCount: 0)
}
