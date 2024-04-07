//
//  ArticleView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/6/24.
//

import SwiftUI

struct ArticleView: View {
    
    @State private var isShowingCreateView: Bool = false
    @State var category: Category = .accua
    
//    private var filteredList: [Int] {
//        switch category {
//        case .nanua: [1, 2, 3, 4, 5, 6]
//        case .baccua: [1, 2, 3, 4, 5, 6]
//        case .accua: [1, 2, 3, 4, 5, 6]
//        case .dasi: [1, 2, 3, 4, 5, 6]
//        }
//    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    CategoryDividerView(category: $category)
                    
                    TabView(selection: $category) {
                        articleListView
                            .tag(Category.accua)
                        articleListView
                            .tag(Category.dasi)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                }
                
                Button {
                    self.isShowingCreateView.toggle()
                } label: {
                    WriteButtonView()
                }
            }
        }
        .navigationTitle("정보 공유")
        .toolbarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingCreateView, content: {
            ArticleCreateView(flag: $category, isShowingCreateView: $isShowingCreateView)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

extension ArticleView {
    var articleListView: some View {
        ScrollView {
            LazyVStack {
//                ForEach(filteredList, id: \.self) { article in
//                        NavigationLink(value: , label: )
//                }
            }
        }
    }
}

#Preview {
    ArticleView()
}
