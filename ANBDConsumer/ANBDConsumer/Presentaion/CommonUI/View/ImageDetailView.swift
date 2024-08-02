//
//  ImageDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    @Binding var isShowingImageDetailView: Bool
    @Binding var images: [URL]
    @Binding var idx: Int
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()
                
                TabView(selection: $idx) {
                    ForEach(0..<images.count, id: \.self) { i in
                        KFImage(images[i])
                            .placeholder { _ in
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(currentZoom + totalZoom)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if totalZoom >= 1.0 {
                                            currentZoom = value - 1
                                        }
                                    }
                                    .onEnded { value in
                                        totalZoom += currentZoom
                                        currentZoom = 0
                                        if totalZoom < 1.0 {
                                            totalZoom = 1.0
                                            currentZoom = 0.0
                                        }
                                    }
                            )
                            .onAppear {
                                currentZoom = 0.0
                                totalZoom = 1.0
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
                
                Spacer()
            }
            .ignoresSafeArea(.all)
            
            HStack {
                Button(action: {
                    isShowingImageDetailView.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.white)
                        .padding(18)
                })
                
                Spacer()
            }
        }
        .background(.black.opacity(0.95))
        .gesture(swipeDownToDismiss)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onEnded { _ in
                isShowingImageDetailView.toggle()
            }
    }
    
    var swipeDownToDismiss: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.height > 0 {
                    offset = gesture.translation
                }
            }
            .onEnded { _ in
                if abs(offset.height) > 100 {
                    isShowingImageDetailView.toggle()
                } else {
                    offset = .zero
                }
            }
    }
}
