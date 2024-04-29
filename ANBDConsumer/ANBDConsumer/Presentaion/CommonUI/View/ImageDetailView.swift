//
//  ImageDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct ImageDetailView: View {
    @Binding var detailImage: Image
    @Binding var isShowingImageDetailView: Bool
    
    @Binding var images: [Data]
    @Binding var idx: Int
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingImageDetailView.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                })
                .padding()
                
                Spacer()
            }
            Spacer()
            
            if images.isEmpty {
                detailImage
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(currentZoom + totalZoom)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentZoom = value - 1
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                currentZoom = 0
                            }
                    )
            } else {
                TabView(selection: $idx) {
                    ForEach(0..<images.count, id: \.self) { i in
                        if let image = UIImage(data: images[i]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(currentZoom + totalZoom)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            currentZoom = value - 1
                                        }
                                        .onEnded { value in
                                            totalZoom += currentZoom
                                            currentZoom = 0
                                        }
                                )
                        } else {
                            ProgressView()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            }
            
            Spacer()
        }
        .background(.black.opacity(0.95))
        .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onEnded { _ in
                isShowingImageDetailView.toggle()
            }
    }
}
