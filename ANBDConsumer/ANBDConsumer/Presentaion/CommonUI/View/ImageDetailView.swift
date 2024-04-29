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
            } else {
                TabView(selection: $idx) {
                    ForEach(0..<images.count, id: \.self) { i in
                        if let image = UIImage(data: images[i]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
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
