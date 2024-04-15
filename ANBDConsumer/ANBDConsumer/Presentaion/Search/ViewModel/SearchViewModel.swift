//
//  SearchViewModel.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/11/24.
//

import Foundation

final class SearchViewModel: ObservableObject {
    @Published var recentSearch: [String] = ["아이패드", "아이폰 15Pro", "맥북", "갤럭시워치", "애플워치"]
}
