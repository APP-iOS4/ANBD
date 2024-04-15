//
//  HomeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

final class HomeViewModel: ObservableObject {
    private let articleUsecase: ArticleUsecase = DefaultArticleUsecase()
    
    @Published var homePath: NavigationPath = NavigationPath()
    
    @Published var bannerItemList: [BannerItem] = BannerItem.mockData
    @Published var accuaArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", imagePaths: [])
    @Published var dasiArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", imagePaths: [])
    
    @Published var nanuaTrades: [Trade] = [.init(writerID: "maru",
                                                 writerNickname: "마루마루",
                                                 category: .nanua,
                                                 itemCategory: .beautyCosmetics,
                                                 location: .busan,
                                                 title: "나눠쓰기마루마루",
                                                 content: "",
                                                 myProduct: "",
                                                 imagePaths: ["DummyPuppy3"]),
                                           .init(writerID: "maru",
                                                 writerNickname: "마루마루",
                                                 category: .nanua,
                                                 itemCategory: .beautyCosmetics,
                                                 location: .busan,
                                                 title: "나눠쓰기메롱메롱",
                                                 content: "",
                                                 myProduct: "",
                                                 imagePaths: ["DummyPuppy1"]),
                                           .init(writerID: "maru",
                                                 writerNickname: "마루마루",
                                                 category: .nanua,
                                                 itemCategory: .beautyCosmetics,
                                                 location: .busan,
                                                 title: "나눠쓰기어쩔어쩔",
                                                 content: "",
                                                 myProduct: "",
                                                 imagePaths: ["DummyPuppy2"]),
                                           .init(writerID: "maru",
                                                 writerNickname: "마루마루",
                                                 category: .nanua,
                                                 itemCategory: .beautyCosmetics,
                                                 location: .busan,
                                                 title: "나눠쓰기어쩔어쩔",
                                                 content: "",
                                                 myProduct: "",
                                                 imagePaths: ["DummyPuppy4"]),]
    @Published var baccuaTrades: [Trade] = [.init(writerID: "maru",
                                                  writerNickname: "마루마루",
                                                  category: .baccua,
                                                  itemCategory: .beautyCosmetics,
                                                  location: .busan,
                                                  title: "바꿔쓰기마루마루",
                                                  content: "",
                                                  myProduct: "키보드",
                                                  imagePaths: ["DummyPuppy3"]),
                                            .init(writerID: "maru",
                                                  writerNickname: "마루마루",
                                                  category: .baccua,
                                                  itemCategory: .beautyCosmetics,
                                                  location: .busan,
                                                  title: "바꿔쓰기메롱메롱",
                                                  content: "",
                                                  myProduct: "뿡이다요",
                                                  imagePaths: ["DummyPuppy1"]),]
    
    
    /// 아껴쓰기 · 다시쓰기 최신 1개씩 가져오기
    func loadArticle(category: ANBDCategory) async {
        do {
            if category == .accua {
                try await accuaArticle = articleUsecase.loadRecentArticle(category: .accua)
            } else if category == .dasi {
                try await dasiArticle = articleUsecase.loadRecentArticle(category: .dasi)
            }
        } catch {
            
        }
    }
}

struct BannerItem: Identifiable {
    private(set) var id: UUID = .init()
    var title: String
    var imageStirng: String
    var url: String
    
    static let mockData: [BannerItem] = [
        .init(title: "3월 22일은 물의 소중함을 알리는 세계 물의 날💧",
              imageStirng: "https://blogfiles.pstatic.net/MjAyNDAzMDhfMjQy/MDAxNzA5ODU3OTU1MDky.7gM8iDEIYO2OCxGeDnPeimUO0EsiWBdAlQScxUo2Dt4g.BBQWmIp3latdi2jbPeGwY_jWyx_erJ4D_awsanupK7Ug.PNG/0306_%EC%84%B8%EA%B3%84%EB%AC%BC%EC%9D%98%EB%82%A0(%EB%8C%80%EC%A7%80)-02.png",
              url: "https://blog.naver.com/PostView.naver?blogId=mesns&logNo=223382133878&categoryNo=15&parentCategoryNo=14&viewDate=&currentPage=3&postListTopCurrentPage=1&from=postList&userTopListOpen=true&userTopListCount=5&userTopListManageOpen=false&userTopListCurrentPage=3"),
        .init(title: "국립공원의 가치를 알리는 3월 3일은 국립공원의 날🌱",
              imageStirng: "https://postfiles.pstatic.net/MjAyNDAyMjdfMTYw/MDAxNzA5MDAwMzY3ODM0._TKSrBBaq8m3HG5Kr2mu-FqV0U3YeO-H64hmYeCVVOkg.xLED3n6xklUBKxEHfyqskx2c6gSmX72hpGaKiv_6ugIg.JPEG/%EB%82%A0%EC%A2%80%EB%B3%B4%EC%86%8C_%EC%9D%B8%EC%8A%A4%ED%83%80v2_02_04.jpg?type=w466",
              url: "https://blog.naver.com/PostView.naver?blogId=mesns&logNo=223368880110&categoryNo=1&parentCategoryNo=14&viewDate=&currentPage=5&postListTopCurrentPage=1&from=postList&userTopListOpen=true&userTopListCount=5&userTopListManageOpen=false&userTopListCurrentPage=5"),
        .init(title: "지구를 지키는 여행법 - 사용하지 않는 콘센트 뽑기",
              imageStirng: "https://postfiles.pstatic.net/MjAyMzA4MDFfNTIg/MDAxNjkwODU2MzAyMzIw.bSisI6_iO4tnvf2T5o8djB5jBUu0-zURf4pQkWwHcRQg.4jdARftzPn0IBh5IUHa23eT85w2zFgBhBehuA9UswiQg.PNG.mesns/05.png?type=w966",
              url: "https://blog.naver.com/PostView.naver?blogId=mesns&logNo=223171647347&categoryNo=27&parentCategoryNo=27&from=thumbnailList")
    ]
}
