//
//  ArticleView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/6/24.
//

import SwiftUI
import ANBDModel

struct ArticleView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    
    @State private var isGoingToSearchView: Bool = false
    @State private var isShowingCreateView: Bool = false
    @State var category: ANBDCategory = .accua
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 45)
                
                TabView(selection: $category) {
                    ArticleListView(category: .accua)
                        .tag(ANBDCategory.accua)
                    ArticleListView(category: .dasi)
                        .tag(ANBDCategory.dasi)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button {
                self.isShowingCreateView.toggle()
            } label: {
                WriteButtonView()
            }
        }
        .navigationTitle("정보 공유")
        .toolbarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingCreateView, content: {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: category, isNewArticle: true)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isGoingToSearchView.toggle()
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                })
            }
        }
        .navigationDestination(isPresented: $isGoingToSearchView) {
            SearchView(category: category)
        }
    }
}


#Preview {
    ArticleView(category: .accua)
        .environmentObject(ArticleViewModel())
}

