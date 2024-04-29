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
            
            detailImage
                .resizable()
                .scaledToFit()
            
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

#Preview {
    NavigationStack {
        ImageDetailView(detailImage: .constant(Image("DummyPuppy1")), isShowingImageDetailView: .constant(true))
    }
}
