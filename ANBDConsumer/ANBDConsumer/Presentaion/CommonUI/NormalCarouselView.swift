//
//  NormalCarouselView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/5/24.
//

import SwiftUI

/// Carousel 프레임을 제공해주는 Component 입니다.
///
/// RandomAccessCollection을 준수하고 Element가 Identifiable을 준수하는 타입을 items로 넣어주시면 됩니다.
///
/// - Parameters:
///     - items: Carousel에 보여줄 item 목록
///     - content: Carousel에 보여줄 View
///
/// - Returns: item을 담고있는 content Carousel
///
struct NormalCarouselView<Content: View>: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var currentIndex: Int? = 0
    
    let items: [BannerItem]
    var content: (BannerItem) -> (Content)
    
    init(
        _ items: [BannerItem],
        content: @escaping (BannerItem) -> (Content)
    ) {
        self.items = items
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Button(action: {
                            homeViewModel.blogURL = items[index].url
                            homeViewModel.isShowingWebView.toggle()
                        }, label: {
                            ZStack(alignment: .bottomLeading) {
                                content(items[index])
                                    .containerRelativeFrame(.horizontal)
                                    .frame(height: 130)
                                    .foregroundStyle(.gray200)
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            }
                            .id(index)
                        })
                    }
                }
                .scrollTargetLayout()
            }
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 60, height: 30)
                .foregroundStyle(.black.opacity(0.3))
                .overlay {
                    Text("\((currentIndex ?? 0) + 1) / \(items.count)")
                        .font(ANBDFont.Caption1)
                        .foregroundStyle(.white)
                }
                .offset(x: -8, y: -8)
            
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentIndex)
    }
}

#Preview {
    NormalCarouselView(BannerItem.mockData) { item in
        Rectangle()
    }
    .environmentObject(HomeViewModel())
}
